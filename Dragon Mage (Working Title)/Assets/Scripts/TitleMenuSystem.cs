using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;
using TMPro;

public class TitleMenuSystem : MonoBehaviour
{
    [SerializeField] Animator menuCursor;
    [SerializeField] ScreenEffects screenEffects;

    [SerializeField] TMP_Text startButton;
    [SerializeField] TMP_Text storyButton;
    [SerializeField] TMP_Text creditsButton;
    [SerializeField] TMP_Text exitButton;

    [SerializeField] GameObject topMenuScreen;
    [SerializeField] GameObject storySubscreen;
    [SerializeField] GameObject creditsSubscreen;

    [SerializeField] InputAction cursorUpAction;
    [SerializeField] InputAction cursorDownAction;

    [SerializeField] InputAction menuSelectAction;
    [SerializeField] InputAction menuBackAction;

    private bool isUpButtonPressed = false;
    private bool isDownButtonPressed = false;
    private bool isSelectButtonPressed = false;
    private bool isBackButtonPressed = false;

    private bool isStartingGame = false;
    private bool isInSubscreen = false;
    private int currentMenuSelection = 0;

    void OnEnable()
    {
        cursorUpAction.Enable();
        cursorDownAction.Enable();
        menuSelectAction.Enable();
        menuBackAction.Enable();
    }

    void OnDisable()
    {
        cursorUpAction.Disable();
        cursorDownAction.Disable();
        menuSelectAction.Disable();
        menuBackAction.Disable();
    }

    void Awake()
    {
        cursorUpAction.started += ctx => { isUpButtonPressed = true; };
        cursorDownAction.started += ctx => { isDownButtonPressed = true; };
        menuSelectAction.started += ctx => { isSelectButtonPressed = true; };
        menuBackAction.started += ctx => { isBackButtonPressed = true; };
    }

    void Start()
    {
        UpdateCursorPosition();
    }

    void Update()
    {
        MoveMenuCursor();
        MakeMenuSelection();
        GoBackToTopMenu();
    }

    void LateUpdate()
    {
        isUpButtonPressed = false;
        isDownButtonPressed = false;
        isSelectButtonPressed = false;
        isBackButtonPressed = false;
    }

    private void MoveMenuCursor()
    {
        if (isStartingGame || isInSubscreen) { return; }

        if ((isUpButtonPressed && !isDownButtonPressed) || (!isUpButtonPressed && isDownButtonPressed))
        {
            if (isUpButtonPressed)
            {
                currentMenuSelection--;
                if (currentMenuSelection < 0) { currentMenuSelection = 3; }
            }
            else
            {
                currentMenuSelection++;
                if (currentMenuSelection > 3) { currentMenuSelection = 0; }
            }
            UpdateCursorPosition();
        }
    }

    private void UpdateCursorPosition()
    {
        switch (currentMenuSelection)
        {
            case 0:
                menuCursor.transform.position = startButton.transform.position;
                break;
            case 1:
                menuCursor.transform.position = storyButton.transform.position;
                break;
            case 2:
                menuCursor.transform.position = creditsButton.transform.position;
                break;
            case 3:
                menuCursor.transform.position = exitButton.transform.position;
                break;
            default:
                break;
        }
    }

    private void MakeMenuSelection()
    {
        if (!isStartingGame && !isInSubscreen && isSelectButtonPressed)
        {
            switch (currentMenuSelection)
            {
                case 0:
                    isStartingGame = true;
                    menuCursor.Play("Select");
                    StartCoroutine(GameStartCR());
                    break;
                case 1:
                    topMenuScreen.SetActive(false);
                    storySubscreen.SetActive(true);
                    isInSubscreen = true;
                    break;
                case 2:
                    topMenuScreen.SetActive(false);
                    creditsSubscreen.SetActive(true);
                    isInSubscreen = true;
                    break;
                case 3:
                    Application.Quit();
                    break;
                default:
                    break;
            }
        }
    }

    private void GoBackToTopMenu()
    {
        if (isInSubscreen && isBackButtonPressed)
        {
            storySubscreen.SetActive(false);
            creditsSubscreen.SetActive(false);
            topMenuScreen.SetActive(true);
            isInSubscreen = false;
        }
    }

    private IEnumerator GameStartCR()
    {
        if (!isStartingGame) { yield break; }

        yield return new WaitForSeconds(1f);

        screenEffects.FadeToBlack(1f);

        yield return new WaitForSeconds(2f);

        SceneManager.LoadScene("A1_L0_Prisoner_Prologue");
    }
}
