//
//  main.cpp
//  CppTest
//
//  Created by Changmook Chun on 9/24/23.
//

#include "dcmtk/dcmimgle/dcmimage.h"
#include "dcmtk/dcmimgle/dipixel.h"
#include "dcmtk/dcmimgle/diimage.h"
#include "dcmtk/dcmimgle/dimo1img.h"
#include "dcmtk/dcmimgle/dimo2img.h"
#include <iostream>

using namespace std;

int main(int argc, char* argv[]) {
    if (DicomImage* image = new DicomImage("test.dcm")) {
        if (image->getStatus() == EIS_Normal) {
            if (image->isMonochrome()) {
                image->setMinMaxWindow();
                Uint8 *pixelData = (Uint8 *)(image->getOutputData(8 /* bits */));
                if (pixelData != NULL) {
                    cout << "Success!\n";
                }
            }
            
        } else {
            cerr << "Error: cannot load DICOM image (" << DicomImage::getString(image->getStatus()) << ")\n";
        }
        
        delete image;
    }
    
    return 0;
}
