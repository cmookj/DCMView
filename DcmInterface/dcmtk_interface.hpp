//
//  dcmtk_interface.hpp
//  DCMView
//
//  Created by Changmook Chun on 9/24/23.
//

#ifndef dcmtk_interface_h
#define dcmtk_interface_h

enum {
    NO_ERR = 0,
    DICOM_NOT_OPEN = 1
};

//#ifdef __cplusplus
//extern "C" {
//#endif

int create_reader(const char* file_name);

unsigned long get_width();
unsigned long get_height();
unsigned long get_frame_count();

int get_depth();

const char* const get_pixel_data_unsigned();
const void* const get_pixel_data_raw();

int signed_representation();
int byte_size_representation();

//#ifdef __cplusplus
//}
//#endif

#endif /* dcmtk_interface_h */
