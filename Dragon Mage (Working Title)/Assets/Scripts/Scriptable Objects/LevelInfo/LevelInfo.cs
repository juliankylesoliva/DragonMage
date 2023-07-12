using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "LevelInfo", menuName = "ScriptableObjects/LevelInfo", order = 2)]
public class LevelInfo : ScriptableObject
{
    [SerializeField] string _sceneName;
    [SerializeField] string _nameHeader;
    [SerializeField, TextArea(10, 15)] string _storyDescription;

    public string sceneName { get { return _sceneName; } }
    public string nameHeader { get { return _nameHeader; } }
    public string storyDescription { get { return _storyDescription; } }
}
