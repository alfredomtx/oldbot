
class _MinimapPosition extends _MinimapPosition.Getters
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New()
    {
    }

    class Getters extends _MinimapPosition.Setters
    {

    }

    class Setters extends _MinimapPosition.Predicates
    {

    }

    class Predicates extends _MinimapPosition.Factory
    {

    }

    class Factory extends _MinimapPosition.Base
    {
        /**
        * Convert a real coord of Tibia Map to a relative position of the screen(screen width and height) to click on the minimap.
        * 
        * @param _MapCoordinate coordinate
        * @return _MinimapPosition
        * @throws
        */
        FROM_MAP_COORDINATE(coordinate)
        {
            static minimapArea
            if (!minimapArea) {
                minimapArea := new _MinimapArea()
            }

            if (!coordinate.isVisibleOnMinimap()) {
                throw Exception(txt("Coordenadas não visíveis(clicáveis) no minimapa(muito longe)", "Coordinates not visible(clickable) on minimap(too far)") ", x: " coordX ", y: " coordY,  "CoordNotVisible")
            }

            coords := new _MinimapPosition()
                , distanceX := coordX - posx
                , distanceY := coordY - posy

            ; minimapArea.getCenter().debug()

            if (distanceX < 0) {
                coords.setX(minimapArea.getCenter().getX() - abs(distanceX))
            } else {
                coords.setX(minimapArea.getCenter().getX() + distanceX)
            }

            if (distanceY < 0) {
                coords.setY(minimapArea.getCenter().getY() - abs(distanceY))
            } else {
                coords.setY(minimapArea.getCenter().getY() + distanceY)
            }

            if (isTibia13() = true) {
                coords.subY(1) ; diminuir 1 px no y para clicar corretamente no SQM
            } else {
                if (isRavendawn()) {
                    coords.addX(distanceX)
                    coords.addY(distanceY)
                }

                coords.addX(CavebotSystem.cavebotJsonObj.coordinates.offsetClickX)
                coords.addY(CavebotSystem.cavebotJsonObj.coordinates.offsetClickY)
            }

            if (coords.X < 0)
                throw Exception("Invalid X coordinate. Coord: " coordX " (" coords.X ")")
            if (coords.Y < 0)
                throw Exception("Invalid Y coordinate. Coord: " coordY " (" coords.Y ")")

            return coords
        }

    }

    class Base extends _Coordinate
    {
    }
}