//
//  c_interface.h
//  DCMView
//
//  Created by Changmook Chun on 9/24/23.
//

#ifndef c_interface_h
#define c_interface_h

enum {
    NO_ERR = 0,
    DICOM_NOT_OPEN = 1
};

#ifdef __cplusplus
extern "C" {
#endif

int create_reader(const char* file_name);

unsigned long get_width();
unsigned long get_height();
unsigned long get_frame_count();

int get_depth();

const unsigned char* const get_pixel_data();

#ifdef __cplusplus
}
#endif

#endif /* c_interface_h */
