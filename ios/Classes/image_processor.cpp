#include "image_processor.hpp"
#include <opencv2/opencv.hpp>

using namespace cv;

Point2f computePoint(int p1, int p2) {
    Point2f pt;
    pt.x = p1;
    pt.y = p2;
    return pt;
}
Mat rotate(Mat src,double angle){
    cv::Point2f center((src.cols-1)/2.0, (src.rows-1)/2.0);
    cv::Mat rot = cv::getRotationMatrix2D(center, angle, 1.0);
    // determine bounding rectangle, center not relevant
    cv::Rect2f bbox = cv::RotatedRect(cv::Point2f(), src.size(), angle).boundingRect2f();
    // adjust transformation matrix
    rot.at<double>(0,2) += bbox.width/2.0 - src.cols/2.0;
    rot.at<double>(1,2) += bbox.height/2.0 - src.rows/2.0;

    cv::Mat dst;
    cv::warpAffine(src, dst, rot, bbox.size());
    return dst;
}
Mat ImageProcessor::process_image(Mat img, float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4,double rotation) {
    cvtColor(img, img, COLOR_BGR2GRAY);
    Mat dst = ImageProcessor::crop_and_transform(img, x1, y1, x2, y2, x3, y3, x4, y4);
    Mat Another= rotate(dst,rotation);
    adaptiveThreshold(Another, Another, 255, cv::ADAPTIVE_THRESH_MEAN_C, cv::THRESH_BINARY, 53, 10);

    return Another;
}

Mat ImageProcessor::crop_and_transform(Mat img, float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {
    float w1 = sqrt( pow(x4 - x3 , 2) + pow(x4 - x3, 2));
    float w2 = sqrt( pow(x2 - x1 , 2) + pow(x2-x1, 2));
    float h1 = sqrt( pow(y2 - y4 , 2) + pow(y2 - y4, 2));
    float h2 = sqrt( pow(y1 - y3 , 2) + pow(y1-y3, 2));

    float maxWidth = (w1 < w2) ? w1 : w2;
    float maxHeight = (h1 < h2) ? h1 : h2;

    Mat dst = Mat::zeros(maxHeight, maxWidth, CV_8UC1);

    vector<Point2f> dst_pts; vector<Point2f> img_pts;
    dst_pts.push_back(Point(0, 0));
    dst_pts.push_back(Point(maxWidth - 1, 0));
    dst_pts.push_back(Point(0, maxHeight - 1));
    dst_pts.push_back(Point(maxWidth - 1, maxHeight - 1));

    img_pts.push_back(computePoint(x1,y1));
    img_pts.push_back(computePoint(x2,y2));
    img_pts.push_back(computePoint(x3,y3));
    img_pts.push_back(computePoint(x4,y4));

    Mat transformation_matrix = getPerspectiveTransform(img_pts, dst_pts);
    warpPerspective(img, dst, transformation_matrix, dst.size());

    return dst;
}
