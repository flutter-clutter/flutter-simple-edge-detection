#include "native_edge_detection.hpp"
#include "edge_detector.hpp"
#include "image_processor.hpp"
#include <stdlib.h>
#include <opencv2/opencv.hpp>


extern "C" __attribute__((visibility("default"))) __attribute__((used))
struct Coordinate *create_coordinate(double x, double y)
{
    struct Coordinate *coordinate = (struct Coordinate *)malloc(sizeof(struct Coordinate));
    coordinate->x = x;
    coordinate->y = y;
    return coordinate;
}

extern "C" __attribute__((visibility("default"))) __attribute__((used))
struct DetectionResult *create_detection_result(Coordinate *topLeft, Coordinate *topRight, Coordinate *bottomLeft, Coordinate *bottomRight)
{
    struct DetectionResult *detectionResult = (struct DetectionResult *)malloc(sizeof(struct DetectionResult));
    detectionResult->topLeft = topLeft;
    detectionResult->topRight = topRight;
    detectionResult->bottomLeft = bottomLeft;
    detectionResult->bottomRight = bottomRight;
    return detectionResult;
}

extern "C" __attribute__((visibility("default"))) __attribute__((used))
struct DetectionResult *detect_edges(char *str) {
    struct DetectionResult *coordinate = (struct DetectionResult *)malloc(sizeof(struct DetectionResult));
    cv::Mat mat = cv::imread(str);

    if (mat.size().width == 0 || mat.size().height == 0) {
        return create_detection_result(
            create_coordinate(0, 0),
            create_coordinate(1, 0),
            create_coordinate(0, 1),
            create_coordinate(1, 1)
        );
    }

    vector<cv::Point> points = EdgeDetector::detect_edges(mat);

    return create_detection_result(
        create_coordinate((double)points[0].x / mat.size().width, (double)points[0].y / mat.size().height),
        create_coordinate((double)points[1].x / mat.size().width, (double)points[1].y / mat.size().height),
        create_coordinate((double)points[2].x / mat.size().width, (double)points[2].y / mat.size().height),
        create_coordinate((double)points[3].x / mat.size().width, (double)points[3].y / mat.size().height)
    );
}

extern "C" __attribute__((visibility("default"))) __attribute__((used))
bool process_image(
    char *path,
    double topLeftX,
    double topLeftY,
    double topRightX,
    double topRightY,
    double bottomLeftX,
    double bottomLeftY,
    double bottomRightX,
    double bottomRightY,
    double rotation
) {
    cv::Mat mat = cv::imread(path);

    cv::Mat resizedMat = ImageProcessor::process_image(
        mat,
        topLeftX * mat.size().width,
        topLeftY * mat.size().height,
        topRightX * mat.size().width,
        topRightY * mat.size().height,
        bottomLeftX * mat.size().width,
        bottomLeftY * mat.size().height,
        bottomRightX * mat.size().width,
        bottomRightY * mat.size().height,
        rotation
    );

    return cv::imwrite(path, resizedMat);
}