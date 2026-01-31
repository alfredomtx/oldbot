
class _ScreenPosition extends _ScreenPosition.Getters
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @throws
    */
    __New(x, y)
    {
        base.__New(x, y)    

        if (x < 0) OR (y < 0) {
            throw Exception("Invalid screen position x:" x ", y:" y ".")
        }

        if (x > WindowWidth) OR (y > WindowHeight) {
            throw Exception("Screen position out of bounds x:" x ", y:" y ".")
        }
    }

    class Getters extends _ScreenPosition.Setters
    {
    }

    class Setters extends _ScreenPosition.Predicates
    {
    }

    class Predicates extends _ScreenPosition.Factory
    {
    }

    class Factory extends _ScreenPosition.Base
    {
        /**
        * returns the real position on screen of the coordinate's SQM
        * @param _MapCoordinate coordinate
        * @return _ScreenPosition 
        * @throws
        */
        SQM_FROM_MAP_COORDINATE(coordinate)
        {
            coords := realCoordsToMinimapRelative(coordinate.getX(), coordinate.getY())
            if (abs(coords.X) > 40) OR (abs(coords.Y) > 22) {
                throw Exception("SQM too distant, distance x:" coords.X ", y:" coords.Y ".")
            }

            SQMX := CHAR_POS_X - (SQM_SIZE / 2)
            if (coords.X < 0)
                SQMX -= SQM_SIZE * abs(coords.X)
            else
                SQMX += SQM_SIZE * coords.X

            SQMY := CHAR_POS_Y - (SQM_SIZE / 2)
            if (coords.Y < 0)
                SQMY -= SQM_SIZE * abs(coords.Y)
            else
                SQMY += SQM_SIZE * coords.Y

            ; adjust to the center
            SQMX += SQM_SIZE / 2
            SQMY += SQM_SIZE / 2

            return new this(SQMX, SQMY)
        }
    }

    class Base extends _Coordinate
    {
    }
}