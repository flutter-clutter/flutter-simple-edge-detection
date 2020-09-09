struct Coordinate
{
    double x;
    double y;
};

struct DetectionResult
{
    Coordinate* topLeft;
    Coordinate* topRight;
    Coordinate* bottomLeft;
    Coordinate* bottomRight;
};

extern "C"
struct DetectionResult *detect_edges(char *str);