using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;

public class AnyKeySceneChange : MonoBehaviour
{
    [SerializeField] InputAction anyKeyAction;
    [SerializeField] string nameOfSceneToChangeTo;

    private bool anyKeyPressed = false;

    void OnEnable()
    {
        anyKeyAction.Enable();
    }

    void OnDisable()
    {
        anyKeyAction.Disable();
    }

    void Awake()
    {
        anyKeyAction.started += ctx => { anyKeyPressed = true; };
    }

    void Update()
    {
        if (anyKeyPressed) { SceneManager.LoadScene(nameOfSceneToChangeTo); }
    }

    void LateUpdate()
    {
        if (anyKeyPressed) { anyKeyPressed = false; }
    }
}
