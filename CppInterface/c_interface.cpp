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
#include <fstream>
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
    const char* _pixel_data_unsigned;
    const void* _pixel_data_raw;
    bool _signed;
    int _byte_size;
    
    unsigned long _width;
    unsigned long _height;
    unsigned long _frame_count;
    int _depth;
    
    reader_state_t _state;
    reader_state_t state() const { return _state; }
    
    // const Uint8 *const pixel_data() const { return _pixel_data; }
    const char* const pixel_data_unsigned() const { return _pixel_data_unsigned; }
    const void* const pixel_data_raw() const { return _pixel_data_raw; }
};

void dump_data_int16(const void* v_ptr, const char* char_ptr) {
    size_t count = 512 * 512;
    std::string file_path_i16 = "/Users/cmookj/Desktop/i16.txt";
    std::string file_path_chr = "/Users/cmookj/Desktop/chr.txt";
   
    std::ofstream strm_i16 {file_path_i16, std::ios::out};
    std::ofstream strm_chr {file_path_chr, std::ios::out};
    
    if (strm_i16.is_open()) {
        for (size_t i = 0; i < count; ++i) {
            strm_i16 << reinterpret_cast<const int16_t*>(v_ptr)[i] << '\n';
        }
    }
    
    if (strm_chr.is_open()) {
        for (size_t i = 0; i < count; ++i) {
            strm_chr << reinterpret_cast<const int16_t*>(char_ptr)[i] << '\n';
        }
    }
}

dicom_reader::dicom_reader(const char* file_name)
: _file_name {file_name}
, _image {std::make_unique<DicomImage>(_file_name.c_str())}
, _pixel_data_unsigned {nullptr}
, _pixel_data_raw {nullptr}
, _signed {false}
, _byte_size {2}
, _width {0}
, _height {0}
, _depth {0}
, _state {reader_state_t::no_error}
{
    if (_image != nullptr) {
        if (_image->getStatus() == EIS_Normal) {
            if (_image->isMonochrome()) {
                _image->setMinMaxWindow();
                
                const DiPixel* pix = _image->getInterData();
                EP_Representation rep = pix->getRepresentation();
                switch (rep) {
                case EPR_Uint8:
                    std::cout << "Unsigned Integer 8\n";
                    _signed = false;
                    _byte_size = 1;
                    break;
                case EPR_Sint8:
                    std::cout << "Signed Integer 8\n";
                    _signed = true;
                    _byte_size = 1;
                    break;
                case EPR_Uint16:
                    std::cout << "Unsigned Integer 16\n";
                    _signed = false;
                    _byte_size = 2;
                    _pixel_data_unsigned = reinterpret_cast<const char*>(_image->getOutputData(16 /* bits */));
                    break;
                    
                case EPR_Sint16:
                    std::cout << " Signed Integer 16\n";
                    _signed = true;
                    _byte_size = 2;
                    _pixel_data_raw = pix->getData();
                    _pixel_data_unsigned = reinterpret_cast<const char*>(_image->getOutputData(16 /* bits */));
                    dump_data_int16(_pixel_data_raw, _pixel_data_unsigned);
                    break;
                case EPR_Uint32:
                    std::cout << "Unsigned Integer 32\n";
                    _signed = false;
                    _byte_size = 4;
                    break;
                case EPR_Sint32:
                    std::cout << "Signed Integer 32\n";
                    _signed = true;
                    _byte_size = 4;
                    break;
                }
                
                if (_pixel_data_unsigned != nullptr) {
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

const char* const get_pixel_data_unsigned() {
    if (is_reader_valid())
        return reinterpret_cast<const char*>(_reader->pixel_data_unsigned());
    
    return nullptr;
}

const void* const get_pixel_data_raw() {
    if (is_reader_valid())
        return _reader->pixel_data_raw();
    
    return nullptr;
}

int signed_representation() {
    if (is_reader_valid())
        return (_reader->_signed ? 1 : 0);
    
    return 0;
}

int byte_size_representation() {
    if (is_reader_valid())
        return _reader->_byte_size;
    
    return 2;
}
