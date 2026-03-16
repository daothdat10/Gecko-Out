using JetBrains.Annotations;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public enum ObjectType
{
    None,
    Snake,
    Obstacle
}


public class LevelDesign : MonoBehaviour
{
    [SerializeField] public int width;
    [SerializeField] public int height;
    [SerializeField] public int level;
    [SerializeField] public InputField inputLevel;
    [SerializeField] public InputField inputWidth;
    [SerializeField] public InputField inputHeight;
    [SerializeField] private ObjectType objType = ObjectType.None;
    [SerializeField] private CellGridEditor cellGridEditor;
    #region Editor Cell Grid

    [Space,Header("____Cell Grid____")]
    [SerializeField] private CellGridEditor prefabsCell;
    [SerializeField] private Transform trfCell;
    [SerializeField] private Button btnCreateGrid;
    [SerializeField] private Transform imgClick;
    private void SpawnGrid()
    {
        width = int.Parse(inputWidth.text);
        height = int.Parse(inputHeight.text);



        for (int i = 0; i < width; i++) {
            for (int j = 0; j < height; j++) {
                Vector3 worldPos = new Vector3(i, 0, j);
                CellGridEditor go = Instantiate(prefabsCell,worldPos,Quaternion.identity,trfCell);
                go.Init(i, j);
                go.name = i + "," + j;
            }
        
        }
    }

    #endregion

    [SerializeField] private SnakeHeadEditor snakeHeadEditor;

    private void Awake()
    {
        btnCreateGrid.onClick.AddListener(SpawnGrid);
    }


    private void MouseLeftClick(int x, int y)
    {
       
    }

    private void EditObjInfo(int x, int y)
    {
        Coord coord = new Coord(x, y);
        Vector2Int vec = new Vector2Int(coord.x, coord.y);
    }

}
