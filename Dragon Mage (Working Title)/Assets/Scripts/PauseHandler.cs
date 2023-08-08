using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;

public class PauseHandler : MonoBehaviour
{
    [SerializeField] GameObject pauseMenu;
    [SerializeField] float holdTime = 3f;

    public static bool isPaused { get; private set; }

    private float currentTitleScreenTimer = 0f;
    private float currentRestartLevelTimer = 0f;
    private bool isWaitingForControlUpdate = false;

    void Update()
    {
        if (InputHub.pauseButtonDown)
        {
            if (isPaused)
            {
                StartCoroutine(WaitForInputVectorCR());
            }
            else
            {
                if (!Level.isLevelComplete)
                {
                    InputHub.playerInput.SwitchCurrentActionMap("Menus");
                    pauseMenu.SetActive(true);
                    isPaused = true;
                    Time.timeScale = 0f;
                    InputHub.ClearInputs();
                }
            }
        }

        if (isPaused && InputHub.titleScreenButtonHeld && !InputHub.menuSelectButtonHeld)
        {
            currentRestartLevelTimer = 0f;
            currentTitleScreenTimer += Time.unscaledDeltaTime;
            if (currentTitleScreenTimer >= holdTime)
            {
                isPaused = false;
                Time.timeScale = 1f;
                SceneManager.LoadScene("TitleScreen");
            }
        }
        else if (isPaused && !InputHub.titleScreenButtonHeld && InputHub.menuSelectButtonHeld)
        {
            currentTitleScreenTimer = 0f;
            currentRestartLevelTimer += Time.unscaledDeltaTime;
            if (currentRestartLevelTimer >= holdTime)
            {
                isPaused = false;
                Time.timeScale = 1f;
                Scene scene = SceneManager.GetActiveScene();
                SceneManager.LoadScene(scene.name);
            }
        }
        else
        {
            currentTitleScreenTimer = 0f;
            currentRestartLevelTimer = 0f;
        }
    }

    private IEnumerator WaitForInputVectorCR()
    {
        if (isWaitingForControlUpdate) { yield break; }
        isWaitingForControlUpdate = true;

        if (!Level.isLevelComplete) { InputHub.playerInput.SwitchCurrentActionMap("In-Game"); }

        yield return null; // PlayerInput needs a frame to read movement input again.

        pauseMenu.SetActive(false);
        isPaused = false;
        Time.timeScale = 1f;
        isWaitingForControlUpdate = false;
    }
}
