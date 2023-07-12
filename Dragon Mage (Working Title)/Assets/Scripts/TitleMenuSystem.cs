using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;
using TMPro;

public class TitleMenuSystem : MonoBehaviour
{
    [SerializeField] LevelInfo[] levelInfoList;

    [SerializeField] Animator menuCursor;
    [SerializeField] ScreenEffects screenEffects;

    [SerializeField] TMP_Text startButton;
    [SerializeField] TMP_Text creditsButton;
    [SerializeField] TMP_Text exitButton;

    [SerializeField] TMP_Text levelSelectText;

    [SerializeField] GameObject topMenuScreen;
    [SerializeField] GameObject levelSelectSubscreen;
    [SerializeField] GameObject creditsSubscreen;

    [SerializeField] InputAction cursorUpAction;
    [SerializeField] InputAction cursorRightAction;
    [SerializeField] InputAction cursorLeftAction;
    [SerializeField] InputAction cursorDownAction;

    [SerializeField] InputAction menuSelectAction;
    [SerializeField] InputAction menuBackAction;

    private bool isUpButtonPressed = false;
    private bool isDownButtonPressed = false;
    private bool isRightButtonPressed = false;
    private bool isLeftButtonPressed = false;
    private bool isSelectButtonPressed = false;
    private bool isBackButtonPressed = false;

    private bool isStartingGame = false;
    private bool isInSubscreen = false;
    private int currentMenuSelection = 0;
    private int currentLevelSelection = 0;

    void OnEnable()
    {
        cursorUpAction.Enable();
        cursorRightAction.Enable();
        cursorLeftAction.Enable();
        cursorDownAction.Enable();
        menuSelectAction.Enable();
        menuBackAction.Enable();
    }

    void OnDisable()
    {
        cursorUpAction.Disable();
        cursorRightAction.Disable();
        cursorLeftAction.Disable();
        cursorDownAction.Disable();
        menuSelectAction.Disable();
        menuBackAction.Disable();
    }

    void Awake()
    {
        cursorUpAction.started += ctx => { isUpButtonPressed = true; };
        cursorRightAction.started += ctx => { isRightButtonPressed = true; };
        cursorLeftAction.started += ctx => { isLeftButtonPressed = true; };
        cursorDownAction.started += ctx => { isDownButtonPressed = true; };
        menuSelectAction.started += ctx => { isSelectButtonPressed = true; };
        menuBackAction.started += ctx => { isBackButtonPressed = true; };
    }

    void Start()
    {
        UpdateCursorPosition();
        UpdateLevelSelectText(levelInfoList[currentLevelSelection]);
    }

    void Update()
    {
        MoveMenuCursor();
        MakeLevelSelection();
        MakeMenuSelection();
        GoBackToTopMenu();
    }

    void LateUpdate()
    {
        isUpButtonPressed = false;
        isDownButtonPressed = false;
        isRightButtonPressed = false;
        isLeftButtonPressed = false;
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
                if (currentMenuSelection < 0) { currentMenuSelection = 2; }
            }
            else
            {
                currentMenuSelection++;
                if (currentMenuSelection > 2) { currentMenuSelection = 0; }
            }
            SoundFactory.SpawnSound("attack_magli_bounce", Vector3.zero, 0.5f);
            SoundFactory.SpawnSound("attack_draelyn_bump", Vector3.zero, 0.5f);
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
                menuCursor.transform.position = creditsButton.transform.position;
                break;
            case 2:
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
                    SoundFactory.SpawnSound("transformation_magli", Vector3.zero, 0.5f);
                    topMenuScreen.SetActive(false);
                    levelSelectSubscreen.SetActive(true);
                    isInSubscreen = true;
                    break;
                case 1:
                    SoundFactory.SpawnSound("transformation_magli", Vector3.zero, 0.5f);
                    topMenuScreen.SetActive(false);
                    creditsSubscreen.SetActive(true);
                    isInSubscreen = true;
                    break;
                case 2:
                    Application.Quit();
                    break;
                default:
                    break;
            }
        }
    }

    private void MakeLevelSelection()
    {
        if (!isStartingGame && isInSubscreen)
        {
            if (isSelectButtonPressed)
            {
                SoundFactory.SpawnSound("attack_magli_blastjump", Vector3.zero, 0.5f);
                SoundFactory.SpawnSound("attack_draelyn_tackle", Vector3.zero, 0.5f);
                isStartingGame = true;
                // menuCursor.Play("Select");
                StartCoroutine(GameStartCR());
            }
            else if ((isLeftButtonPressed || isRightButtonPressed) && !(isLeftButtonPressed && isRightButtonPressed))
            {
                if (isLeftButtonPressed)
                {
                    if (currentLevelSelection > 0) { currentLevelSelection--; }
                    else { currentLevelSelection = (levelInfoList.Length - 1); }
                }
                else if (isRightButtonPressed)
                {
                    if (currentLevelSelection < (levelInfoList.Length - 1)) { currentLevelSelection++; }
                    else { currentLevelSelection = 0; }
                }
                else { /* Nothing */ }

                SoundFactory.SpawnSound("attack_magli_bounce", Vector3.zero, 0.5f);
                SoundFactory.SpawnSound("attack_draelyn_bump", Vector3.zero, 0.5f);
                UpdateLevelSelectText(levelInfoList[currentLevelSelection]);
            }
            else { /* Nothing */ }
        }
    }

    private void UpdateLevelSelectText(LevelInfo info)
    {
        levelSelectText.text = $"<b><i>{info.nameHeader}</b></i>\n\n<size=3>{info.storyDescription}</size>";
    }

    private void GoBackToTopMenu()
    {
        if (isInSubscreen && isBackButtonPressed)
        {
            SoundFactory.SpawnSound("transformation_draelyn", Vector3.zero, 0.5f);
            levelSelectSubscreen.SetActive(false);
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

        SceneManager.LoadScene(levelInfoList[currentLevelSelection].sceneName);
    }
}
