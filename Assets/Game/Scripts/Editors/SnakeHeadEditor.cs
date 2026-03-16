using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SnakeHeadEditor : MonoBehaviour
{
    public ObjectType objectType;
    [SerializeField] private SnakeEditor snakeHeadEditor;
    [SerializeField] private SnakeEditor snakeBody;
    [SerializeField] private SnakeEditor snakeTailEditor;
}
