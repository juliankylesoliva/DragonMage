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
                InputHub.playerInput.SwitchCurrentActionMap("Menus");
                pauseMenu.SetActive(true);
                isPaused = true;
                Time.timeScale = 0f;
                InputHub.ClearInputs();
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

    private IEnumerator WaitForInputVectorCR()
    {
        if (isWaitingForControlUpdate) { yield break; }
        isWaitingForControlUpdate = true;

        InputHub.playerInput.SwitchCurrentActionMap("In-Game");

        yield return null; // PlayerInput needs a frame to read movement input again.

        pauseMenu.SetActive(false);
        isPaused = false;
        Time.timeScale = 1f;
        isWaitingForControlUpdate = false;
    }
}
