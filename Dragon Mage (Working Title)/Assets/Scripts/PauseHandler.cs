using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;

public class PauseHandler : MonoBehaviour
{
    [SerializeField] GameObject pauseMenu;

    [SerializeField] InputAction pauseAction;
    [SerializeField] InputAction titleScreenAction;

    public static bool isPaused { get; private set; }
    private bool isPauseButtonPressed = false;
    private bool isTitleScreenButtonHeld = false;

    private float currentTitleScreenTimer = 0f;

    void OnEnable()
    {
        pauseAction.Enable();
        titleScreenAction.Enable();
    }

    void OnDisable()
    {
        pauseAction.Disable();
        titleScreenAction.Disable();
    }

    void Awake()
    {
        pauseAction.started += ctx => { isPauseButtonPressed = true; };
        titleScreenAction.started += ctx => { isTitleScreenButtonHeld = true; };
        titleScreenAction.canceled += ctx => { isTitleScreenButtonHeld = false; };
    }

    void Update()
    {
        if (isPauseButtonPressed)
        {
            if (isPaused)
            {
                pauseMenu.SetActive(false);
                isPaused = false;
                Time.timeScale = 1f;
            }
            else
            {
                pauseMenu.SetActive(true);
                isPaused = true;
                Time.timeScale = 0f;
            }
        }

        if (isPaused && isTitleScreenButtonHeld)
        {
            currentTitleScreenTimer += Time.unscaledDeltaTime;
            if (currentTitleScreenTimer >= 3f)
            {
                Time.timeScale = 1f;
                isPaused = false;
                Time.timeScale = 1f;
                SceneManager.LoadScene("TitleScreen"); }
        }
        else
        {
            currentTitleScreenTimer = 0f;
        }
    }

    void LateUpdate()
    {
        if (isPauseButtonPressed) { isPauseButtonPressed = false; }
    }
}
