#!/bin/python

#
# This scripy is used to analyze the maps file of a process.
# It summarize the memory usage statistics of heap, stack, 
# memory_mapped files, and larger size anonymous memories.
#
# Each line of a maps file usually consists of six parts:
# 1) *address* - This is the starting and ending address of the region in the process's address space
# 2) *permissions* - This describes how pages in the region can be accessed. 
#    There are four different permissions: read, write, execute, and shared. 
#    If read/write/execute are disabled, a '-' will appear instead of the 'r'/'w'/'x'. 
#    If a region is not shared, it is private, so a 'p' will appear instead of an 's'. 
#    If the process attempts to access memory in a way that is not permitted, a segmentation fault is generated. 
#    Permissions can be changed using the mprotect system call.
# 3) *offset* - If the region was mapped from a file (using mmap), this is the offset 
#    in the file where the mapping begins. If the memory was not mapped from a file, it's just 0.
# 4) *device* - If the region was mapped from a file, this is the major and minor device number (in hex) where the file lives.
# 5) *inode* - If the region was mapped from a file, this is the file number.
# 6) *pathname* - If the region was mapped from a file, this is the name of the file. 
#     This field is blank for anonymous mapped regions. 
#     There are also special regions with names like [heap], [stack], or [vdso]. 
#     [vdso] stands for virtual dynamic shared object. It's used by system calls to switch to kernel mode. 
#     Here's a good article about it.
#     (http://www.trilithium.com/johan/2005/08/linux-gate/)
#
# @author: yuejun.huyj (yilang)
# @date: 2012-08-18
# 
import os
import sys

# The parameter 'addr_range' is in the format "2ba9f3bcf000-2ba9f3dce000"
def process_address(addr_range):
    temp = addr_range.split('-')
    start_addr = long(temp[0], 16)
    end_addr = long(temp[1], 16)
    return (start_addr, end_addr)


class MemMapAnalyzer(object):
    def __init__(self, mmaps_file_name):

        self.mmaps_file_name = mmaps_file_name

        # The enum values denoting the states when analyzing the maps file.
        self.START, self.HEAP, self.MMAPS, self.STACK, self.VDSO, self.END = range(6)
        self.state = self.START

        # The memory used by the following sections
        self.heap_mem_size = 0
        self.file_mmap_size = 0
        self.anon_mmap_size = 0
        self.stack_size = 0
        self.vdso_size = 0

        # The anonymous memory address which is just bigger than this limit
        # would be the starting of the heap address, if the [heap] pathname is absent.
        self.heap_offset_limit = 0x1000000

        self.heap_path_name = '[heap]'
        self.stack_path_name = '[stack]'
        self.vdso_path_name = '[vdso]'

        # Invalid memory delimiter
        self.invalid_mem_section = '---p'

        # The lists to hold the memory usuage details of heap and anonymous memory
        self.heap_details = []
        self.anon_details = []
        self.file_details = []

    def process(self):
        maps_file = open(self.mmaps_file_name, 'rb')

        #  Now line by line to process the maps file
        for line in maps_file:
            # Trim the ending "\n" character
            line = line.strip()
            if (len(line) == 0):
                break

            parts = line.split()
            (addr_begin, addr_end) = process_address(parts[0])

            if self.state == self.START:
                # If "[heap]" is specific, or implicit
                if ((len(parts) == 6 and parts[-1] == self.heap_path_name) or 
                   (len(parts) == 5 and parts[-1] == '0' and addr_begin >= self.heap_offset_limit)):
                    self.state = self.HEAP
                    if (parts[1] != self.invalid_mem_section):
                        self.heap_mem_size += addr_end - addr_begin
                        self.heap_details.append((parts[0], parts[1], addr_end - addr_begin))
                    continue
            elif self.state == self.HEAP:
                if (len(parts) == 5 and parts[-1] == '0'):
                    # Still in the HEAP memory area
                    if (parts[1] != self.invalid_mem_section):
                        self.heap_mem_size += addr_end - addr_begin
                        self.heap_details.append((parts[0], parts[1], addr_end - addr_begin))
                    continue
                else:
                    # Now coming to the MMAPS state
                    self.state = self.MMAPS
                    if (parts[1] != self.invalid_mem_section):
                        self.file_mmap_size += addr_end - addr_begin
                        self.file_details.append((parts[0], parts[1], addr_end - addr_begin, parts[-1]))
            elif self.state == self.MMAPS:
                if (len(parts) == 5 and parts[-1] == '0'):
                    if (parts[1] != self.invalid_mem_section):
                        self.anon_mmap_size += addr_end - addr_begin
                        self.anon_details.append((parts[0], parts[1], addr_end - addr_begin))
                    continue

                if (len(parts) == 6):
                    if (parts[-1] != self.stack_path_name):
                        if (parts[1] != self.invalid_mem_section):
                            self.file_mmap_size += addr_end - addr_begin
                            self.file_details.append((parts[0], parts[1], addr_end - addr_begin, parts[-1]))
                    else:
                        self.state = self.STACK
                        if (parts[1] != self.invalid_mem_section):
                            self.stack_size += addr_end - addr_begin

                        # Double check the inode
                        if (parts[4] != '0'):
                            print "ERROR: The stack analysis is not correct!"
                            sys.exit(1)

                    continue
            elif self.state == self.STACK:
                # Usually the stack memory area is followed by vdso memory area
                if (len(parts) == 6 and parts[-1] == self.vdso_path_name):
                    self.state = self.VDSO
                    self.vdso_size += addr_end - addr_begin
                    break
                else:
                    print "WARN: The vdso memory is not immediately following stack!"
                    
                    if (len(parts) == 5 and parts[-1] == '0'):
                        stack_size += addr_end - addr_begin
                continue

    # Print the analysis result
    def print_result(self):
        print "===========Memory Usage Summary=============="
        print "heap:        %ldM" % (self.heap_mem_size/1024/1024) 
        print "mmap_anon:   %ldM" % (self.anon_mmap_size/1024/1024) 
        print "stack:       %ldM" % (self.stack_size/1024/1024)  
        print "mmap_file:   %ldM" % (self.file_mmap_size/1024/1024)  
        print "vdso:        %ldM" % (self.vdso_size/1024/1024)

        # Print the memory usage details according to the command line arguments
        if '--heap' in sys.argv[1:]:
            print "\n====================Heap Usage Details=================="
            for (mem_range, perm, size) in self.heap_details:
                print "%s  %s:  %ldK" % (mem_range, perm, size/1024)
        
        if '--anon' in sys.argv[1:]:
            print "\n====================Anonymous Memeory Usage Details=================="
            for (mem_range, perm, size) in self.anon_details:
                print "%s  %s:  %ldK" % (mem_range, perm, size/1024)
            
        if '--file' in sys.argv[1:]:
            print "\n====================Memory Mapped files Usage Details=================="
            for (mem_range, perm, size, filename) in self.file_details:
                print "%s  %s  %s:  %ldK" % (mem_range, perm, filename, size/1024)

        print "=======================END================================"

def main():
    if len(sys.argv) < 2:
        print "Usage: python mem_analyzer maps_filepath [--heap] [--anon] [--file]"
        sys.exit(1)
    
    maps_filename = sys.argv[1]
    
    # Check whether the maps_file exists
    if (os.path.isfile(maps_filename) == False):
        print "The maps_file %s doesn't exist!" % maps_filename
        sys.exit(1)

    mmap_analyzer = MemMapAnalyzer(maps_filename)
    mmap_analyzer.process()
    mmap_analyzer.print_result()

if __name__ == '__main__':
    main()

