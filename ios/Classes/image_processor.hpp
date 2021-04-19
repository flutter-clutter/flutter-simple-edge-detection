#include <opencv2/opencv.hpp>

using namespace cv;
using namespace std;


class ImageProcessor {
    public:
    static Mat process_image(Mat img, float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4,double rotation);

    private:
    static Mat crop_and_transform(Mat img, float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4);
};
