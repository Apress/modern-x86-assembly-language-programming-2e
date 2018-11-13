#pragma once
#include <windows.h>
#include <objidl.h>
#include <gdiplus.h>
#include <malloc.h>
#include <stdexcept>
#include <cstdint>
#include <memory>

#pragma comment (lib,"Gdiplus.lib")

using namespace Gdiplus;

struct RGB32
{
    uint8_t m_R;
    uint8_t m_G;
    uint8_t m_B;
    uint8_t m_A;
};

enum class PixelType : unsigned int
{
    Undefined,
    Gray8,
    Rgb32
};

class ImageMatrix
{
    static const unsigned int c_PixelBufferAlignment = 64;      // Alignment for AVX, AVX2, and AVX-512

    int m_Height;
    int m_Width;
    int m_BytesPerPixel;
    int m_PixelBufferSize;
    void* m_PixelBuffer;
    PixelType m_Type;

    void AllocatePixelBuffer(int height, int width, PixelType type)
    {
        if (type == PixelType::Gray8)
            m_BytesPerPixel = 1;
        else if (type == PixelType::Rgb32)
            m_BytesPerPixel = sizeof(RGB32);
        else
            throw std::runtime_error("AllocatePixelBuffer() - Invalid type");

        m_Height = height;
        m_Width = width;
        m_PixelBufferSize = height * width * m_BytesPerPixel;
        m_Type = type;
        m_PixelBuffer = _aligned_malloc(m_PixelBufferSize, c_PixelBufferAlignment);
    };

    static int GetEncoderClsid(const WCHAR* format, CLSID* pClsid)
    {
        unsigned int num = 0;                       // number of image encoders
        unsigned int size = 0;                      // size of the image encoder array in bytes
        ImageCodecInfo* image_codec_info = NULL;

        GetImageEncodersSize(&num, &size);

        if (size == 0)
            return -1;  // Failure

        if ((image_codec_info = (ImageCodecInfo*)(malloc(size))) == NULL)
            return -1;

        GetImageEncoders(num, size, image_codec_info);

        for (unsigned int j = 0; j < num; ++j)
        {
            if (wcscmp(image_codec_info[j].MimeType, format) == 0)
            {
                *pClsid = image_codec_info[j].Clsid;
                free(image_codec_info);
                return j;
            }    
        }

        free(image_codec_info);
        return -1;  // Failure
    }

public:
    int GetHeight() const                           { return m_Height; }
    int GetWidth() const                            { return m_Width; }
    int GetNumPixels() const                        { return m_Height * m_Width; }
    int GetBytesPerPixel() const                    { return m_BytesPerPixel; }
    int GetPixelBufferSize() const                  { return m_PixelBufferSize; }
    PixelType GetPixelBufferType() const            { return m_Type; }
    template <typename T> T* GetPixelBuffer(void)   { return (T*)m_PixelBuffer; }

    ImageMatrix(void) = delete;
    ImageMatrix(const ImageMatrix& im) = delete;
    ImageMatrix(ImageMatrix&& im) = delete;
    ImageMatrix& operator = (const ImageMatrix& im) = delete;
    ImageMatrix& operator = (ImageMatrix&& im) = delete;

    ImageMatrix(const wchar_t* filename)
    {
        ULONG_PTR GdiToken;
        GdiplusStartupInput GdiInput;
        Gdiplus::Status status = GdiplusStartup(&GdiToken, &GdiInput, NULL);

        if (status == Gdiplus::Ok)
        {
            std::string ex_msg;
            Bitmap* bm = nullptr;
            bool ex_occurred = false;

            try
            {
                bm =  new Bitmap(filename, FALSE);
                PixelFormat pixel_format = bm->GetPixelFormat();

                if (pixel_format == PixelFormat8bppIndexed)
                {
                    AllocatePixelBuffer(bm->GetHeight(), bm->GetWidth(), PixelType::Gray8);
                    uint8_t* pb = (uint8_t*)m_PixelBuffer;

                    for (int i = 0; i < m_Height; i++)
                    {
                        for (int j = 0; j < m_Width; j++)
                        {
                            Gdiplus::Color c;

                            if (bm->GetPixel(j, i, &c) != Gdiplus::Ok)
                                throw std::runtime_error("ImageMatrix::ImageMatrix - Bitmap::GetPixel() error occurred");

                            *pb++ = c.GetGreen();
                        }
                    }
                }
                else if (pixel_format == PixelFormat24bppRGB)
                {
                    AllocatePixelBuffer(bm->GetHeight(), bm->GetWidth(), PixelType::Rgb32);
                    RGB32* pb = (RGB32*)m_PixelBuffer;

                    for (int i = 0; i < m_Height; i++)
                    {
                        for (int j = 0; j < m_Width; j++)
                        {
                            RGB32 rgb;
                            Gdiplus::Color c;

                            if (bm->GetPixel(j, i, &c) != Gdiplus::Ok)
                                throw std::runtime_error("ImageMatrix::ImageMatrix - Bitmap::GetPixel() error occurred");

                            rgb.m_R = c.GetRed();
                            rgb.m_G = c.GetGreen();
                            rgb.m_B = c.GetBlue();
                            rgb.m_A = 0;

                            *pb++ = rgb;
                        }
                    }
                }   
                else
                    throw std::runtime_error("ImageMatrix::ImageMatrix(const wchar_t* bitmap_filename) - Unsupported pixel format");
            }

            catch (const std::exception& ex)
            {
                ex_msg = ex.what();
                ex_occurred = true;
            }

            // Bitmap must be deleted before GdiplusShutdown.
            if (bm != nullptr)
                delete bm;

            GdiplusShutdown(GdiToken);

            if (ex_occurred)
                throw std::runtime_error(ex_msg); 
        }
    }

    ImageMatrix(int height, int width, PixelType type)
    {
        AllocatePixelBuffer(height, width, type);
    }

    ~ImageMatrix(void)
    {
        _aligned_free(m_PixelBuffer);
    }

    void SaveToBitmapFile(const wchar_t* filename)
    {
        ULONG_PTR GdiToken;
        GdiplusStartupInput GdiInput;
        Gdiplus::Status status = GdiplusStartup(&GdiToken, &GdiInput, NULL);

        if (status == Gdiplus::Ok)
        {
            std::string ex_msg;
            Bitmap* bm = nullptr;
            Gdiplus::ColorPalette* cp = nullptr;
            bool ex_occurred = false;

            try
            {
                BitmapData bitmapData;
                Rect rect(0, 0, m_Width, m_Height);

                if (m_Type == PixelType::Gray8)
                {
                    if (m_Width % 4 == 0)
                    {
                        bm = new Bitmap(m_Width, m_Height, PixelFormat8bppIndexed);
                        cp = (Gdiplus::ColorPalette*)malloc(sizeof(Gdiplus::ColorPalette) + 256 * sizeof(Gdiplus::ARGB));

                        cp->Flags = Gdiplus::PaletteFlags::PaletteFlagsGrayScale;
                        cp->Count = 256;

                        for (int i = 0; i < 256; i++)
                        {
                            BYTE r = (BYTE)i;
                            BYTE g = (BYTE)i;
                            BYTE b = (BYTE)i;
                            ARGB argb = Gdiplus::Color::MakeARGB(0, r, g, b);

                            cp->Entries[i] = argb;
                        }

                        bm->SetPalette(cp);
                        bm->LockBits(&rect, ImageLockModeWrite, PixelFormat8bppIndexed, &bitmapData);

                        uint8_t* pb_src = (uint8_t*)m_PixelBuffer;
                        uint8_t* pb_des = (uint8_t*)bitmapData.Scan0;
                        memcpy(pb_des, pb_src, m_Height * m_Width);
                        bm->UnlockBits(&bitmapData);
                    }
                    else
                        throw std::runtime_error("ImageMatrix::SaveToBitmapFile(const wchar_t* filename) - Bitmap width must be evenly divisible by 4");
                }
                else if (m_Type == PixelType::Rgb32)
                {
                    bm = new Bitmap(m_Width, m_Height, PixelFormat24bppRGB);

                    RGB32* pb_src = (RGB32*)m_PixelBuffer;
                    Gdiplus::Color c;

                    for (int i = 0; i < m_Height; i++)
                    {
                        for (int j = 0; j < m_Width; j++)
                        {
                            RGB32 rgb = *pb_src++;
                            ARGB argb = Gdiplus::Color::MakeARGB(0, rgb.m_R, rgb.m_G, rgb.m_B);

                            c.SetValue(argb);

                            if (bm->SetPixel(j, i, c) != Gdiplus::Ok)
                                throw std::runtime_error("ImageMatrix::SaveToBitmapFile(const wchar_t* filename) - SetPixel() error occurred");
                        }
                    }
                }
                else
                    throw std::runtime_error("ImageMatrix::SaveToBitmapFile(const wchar_t* filename) - Unsupported pixel format");

                CLSID pngClsid;

                GetEncoderClsid(L"image/bmp", &pngClsid);
                status = bm->Save(filename, &pngClsid, NULL);
            }

            catch (const std::exception& ex)
            {
                ex_msg = ex.what();
                ex_occurred = true;
            }

            if (bm != nullptr)
                delete bm;

            if (cp != nullptr)
                free(cp);

            GdiplusShutdown(GdiToken);

            if (ex_occurred)
                throw std::runtime_error(ex_msg);
        }
    }

    void AllocRgbArrays(uint8_t** r, uint8_t** g, uint8_t** b, unsigned int alignment)
    {
        if (m_Type != PixelType::Rgb32)
            throw std::runtime_error("ImageMatrix::AllocRgbArrays(size_t alignment) - Invalid 'Type' value");

        *r = (uint8_t*)_aligned_malloc(m_Width * m_Height * sizeof(uint8_t), alignment);
        *g = (uint8_t*)_aligned_malloc(m_Width * m_Height * sizeof(uint8_t), alignment);
        *b = (uint8_t*)_aligned_malloc(m_Width * m_Height * sizeof(uint8_t), alignment);
    }

    void FreeRgbArrays(uint8_t* r, uint8_t* g, uint8_t* b)
    {
        if (m_Type != PixelType::Rgb32)
            throw std::runtime_error("ImageMatrix::FreeRgbArrays(size_t alignment) - Invalid 'Type' value");

        _aligned_free(r);
        _aligned_free(g);
        _aligned_free(b);
    }

    void GetRgbPixelData(uint8_t* r, uint8_t* g, uint8_t* b)
    {
        if (m_Type != PixelType::Rgb32)
            throw std::runtime_error("ImageMatrix::GetRgbPixelData(Uint8* r, Uint8* g, Uint8* b) - Invalid 'Type' value");

        RGB32* pb = (RGB32*)m_PixelBuffer;

        for (int i = 0; i < m_Height * m_Width; i++, pb++)
        {
            *r++ = pb->m_R;
            *g++ = pb->m_G;
            *b++ = pb->m_B;
        }
    }

    void SetRgbPixelData(const uint8_t* r, const uint8_t* g, const uint8_t* b)
    {
        if (m_Type != PixelType::Rgb32)
            throw std::runtime_error("ImageMatrix::SetRgbPixelData(const Uint8* r, const Uint8* g, const Uint8* b) - Invalid 'Type' value");

        RGB32* pb = (RGB32*)m_PixelBuffer;

        for (int i = 0; i < m_Height * m_Width; i++, pb++)
        {
            pb->m_R = *r++;
            pb->m_G = *g++;
            pb->m_B = *b++;
        }
    }
};
