using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class LevelModel 
{
    public List<SnakeInfo> snakeInfos;
}

[System.Serializable]
public class SnakeInfo
{
    public SnakeInfo(SnakeInfo snakeInfo)
    {
        colorID = new List<int>(snakeInfo.colorID);
        bodyPosition = new List<Coord>(snakeInfo.bodyPosition);
        connectID = snakeInfo.connectID;
    }

    public SnakeInfo()
    {
        colorID = new List<int>();
        bodyPosition = new List<Coord>();
    }

    public int Length
    {
        get
        {
            if(bodyPosition == null)
            {
                return 0;
            }
            return bodyPosition.Count;
        }
    }

    public int connectID;
    public List<int> colorID;
    public List<Coord> bodyPosition;


}
[System.Serializable]
public struct Coord
{
    public Coord(int _x, int _y) {
        x = _x;
        y = _y;
    }

    public Coord(Vector2Int vector)
    {
        x = vector.x;
        y = vector.y;
    }

    public int x;
    public int y;

    public Vector2Int ToVector2Int()
    {
        return new Vector2Int(x, y);
    }
}

