using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;

public class PauseHandler : MonoBehaviour
{
    [SerializeField] GameObject pauseMenu;

    public static bool isPaused { get; private set; }

    private float currentTitleScreenTimer = 0f;

    void Update()
    {
        if (InputHub.pauseButtonDown)
        {
            if (isPaused)
            {
                InputHub.playerInput.SwitchCurrentActionMap("In-Game");
                pauseMenu.SetActive(false);
                isPaused = false;
                Time.timeScale = 1f;
            }
            else
            {
                InputHub.playerInput.SwitchCurrentActionMap("Menus");
                pauseMenu.SetActive(true);
                isPaused = true;
                Time.timeScale = 0f;
            }
        }

        if (isPaused && InputHub.titleScreenButtonHeld)
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
}
