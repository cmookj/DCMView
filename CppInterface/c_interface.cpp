//
//  c_interface.cpp
//  DCMView
//
//  Created by Changmook Chun on 9/24/23.
//

#include "c_interface.h"

#include "dcmtk/dcmimgle/dcmimage.h"
#include "dcmtk/dcmimgle/dipixel.h"
#include "dcmtk/dcmimgle/diimage.h"
#include "dcmtk/dcmimgle/dimo1img.h"
#include "dcmtk/dcmimgle/dimo2img.h"

#include <iostream>
#include <memory>
#include <string>

enum class reader_state_t {
    no_error,
    dicom_not_open
};

// *****************************************************************************
#pragma mark - DICOM READER

struct dicom_reader {
    dicom_reader() = delete;
    dicom_reader(const char*);
    virtual ~dicom_reader() = default;
    
    std::string _file_name;
    std::unique_ptr<DicomImage> _image;
    Uint8* _pixel_data;
    unsigned long _width;
    unsigned long _height;
    unsigned long _frame_count;
    int _depth;
    
    reader_state_t _state;
    reader_state_t state() const { return _state; }
    
    const Uint8 *const pixel_data() const { return _pixel_data; }
};

dicom_reader::dicom_reader(const char* file_name)
: _file_name {file_name}
, _image {std::make_unique<DicomImage>(_file_name.c_str())}
, _pixel_data {nullptr}
, _width {0}
, _height {0}
, _depth {0}
, _state {reader_state_t::no_error}
{
    if (_image != nullptr) {
        if (_image->getStatus() == EIS_Normal) {
            if (_image->isMonochrome()) {
                _image->setMinMaxWindow();
                _pixel_data = (Uint8 *)(_image->getOutputData(8 /* 8 *//* bits */));
                if (_pixel_data != nullptr) {
                    std::cout << "Success!\n";
                    
                    _width = _image->getWidth();
                    _height = _image->getHeight();
                    _frame_count = _image->getFrameCount();
                    
                    _depth = _image->getDepth();
                    
                    std::cout << " -       Width: " << _width << '\n';
                    std::cout << " -      Height: " << _height << '\n';
                    std::cout << " - Frame count: " << _frame_count << '\n';
                    std::cout << " -       Depth: " << _depth << '\n';
                }
            }
            
        } else {
            std::cerr << "Error: cannot load DICOM image (" 
                    << DicomImage::getString(_image->getStatus()) << ")\n";
            _state = reader_state_t::dicom_not_open;
        }
    }
}


static std::unique_ptr<dicom_reader> _reader = nullptr;


// *****************************************************************************
#pragma mark - INTERNAL FUNCTIONS
static bool is_reader_valid() {
    return (_reader != nullptr && _reader->state() == reader_state_t::no_error);
}

#pragma mark - INTERFACE FUNCTIONS

int create_reader(const char* file_name) {
    _reader = std::make_unique<dicom_reader>(file_name);
    switch (_reader->state()) {
    case reader_state_t::no_error:
        return NO_ERR;
        break;
        
    case reader_state_t::dicom_not_open:
        return DICOM_NOT_OPEN;
        break;
    }
}

unsigned long get_width() {
    if (is_reader_valid())
        return _reader->_width;
    
    return 0;
}

unsigned long get_height() {
    if (is_reader_valid())
        return _reader->_height;
    
    return 0;
}

unsigned long get_frame_count() {
    if (is_reader_valid())
        return _reader->_frame_count;
    
    return 0;
}

int get_depth() {
    if (is_reader_valid())
        return _reader->_depth;
    
    return 0;
}

const unsigned char* const get_pixel_data() {
    if (is_reader_valid())
        return _reader->pixel_data();
    
    return nullptr;
}
