//
//  Memory.swift
//  Shitmulation
//
//  Created by syan on 23/05/2023.
//

import Foundation

struct Memory {
    static var currentUsedSize: UInt64 {
        var taskInfo = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size) / 4
        let result: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
           $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
               task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
           }
        }
        guard result == KERN_SUCCESS else { return 0 }
        return taskInfo.phys_footprint
    }
    
    static var peakMemoryUsage: UInt64 = 0
    
    static func updatePeakMemoryUsage() {
        peakMemoryUsage = max(peakMemoryUsage, currentUsedSize)
    }
}
