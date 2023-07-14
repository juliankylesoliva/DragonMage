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

    [SerializeField] TMP_Text creditsText;
    [SerializeField] int creditPages = 2;

    private bool isStartingGame = false;
    private bool isInSubscreen = false;
    private int currentMenuSelection = 0;
    private int currentLevelSelection = 0;

    void Start()
    {
        UpdateCursorPosition();
        UpdateLevelSelectText(levelInfoList[currentLevelSelection]);
    }

    void Update()
    {
        MoveMenuCursor();
        CreditsPage();
        MakeLevelSelection();
        MakeMenuSelection();
        GoBackToTopMenu();
    }

    private void MoveMenuCursor()
    {
        if (isStartingGame || isInSubscreen) { return; }

        if ((InputHub.menuUpButtonDown && !InputHub.menuDownButtonDown) || (!InputHub.menuUpButtonDown && InputHub.menuDownButtonDown))
        {
            if (InputHub.menuUpButtonDown)
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
        if (!isStartingGame && !isInSubscreen && InputHub.menuSelectButtonDown)
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
                    creditsText.pageToDisplay = 1;
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
        if (!isStartingGame && isInSubscreen && levelSelectSubscreen.activeSelf)
        {
            if (InputHub.menuSelectButtonDown)
            {
                SoundFactory.SpawnSound("attack_magli_blastjump", Vector3.zero, 0.5f);
                SoundFactory.SpawnSound("attack_draelyn_tackle", Vector3.zero, 0.5f);
                isStartingGame = true;
                // menuCursor.Play("Select");
                StartCoroutine(GameStartCR());
            }
            else if ((InputHub.menuLeftButtonDown || InputHub.menuRightButtonDown) && !(InputHub.menuLeftButtonDown && InputHub.menuRightButtonDown))
            {
                if (InputHub.menuLeftButtonDown)
                {
                    if (currentLevelSelection > 0) { currentLevelSelection--; }
                    else { currentLevelSelection = (levelInfoList.Length - 1); }
                }
                else if (InputHub.menuRightButtonDown)
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

    private void CreditsPage()
    {
        if (!isStartingGame && isInSubscreen && creditsSubscreen.activeSelf)
        {
            if ((InputHub.menuLeftButtonDown || InputHub.menuRightButtonDown) && !(InputHub.menuLeftButtonDown && InputHub.menuRightButtonDown))
            {
                if (InputHub.menuLeftButtonDown)
                {
                    if (creditsText.pageToDisplay > 1) { creditsText.pageToDisplay--; }
                    else { creditsText.pageToDisplay = creditPages; }
                }
                else if (InputHub.menuRightButtonDown)
                {
                    if (creditsText.pageToDisplay < creditPages) { creditsText.pageToDisplay++; }
                    else { creditsText.pageToDisplay = 1; }
                }
                else { /* Nothing */ }

                SoundFactory.SpawnSound("attack_magli_bounce", Vector3.zero, 0.5f);
                SoundFactory.SpawnSound("attack_draelyn_bump", Vector3.zero, 0.5f);
            }
        }
    }

    private void UpdateLevelSelectText(LevelInfo info)
    {
        levelSelectText.text = $"<b><i>{info.nameHeader}</b></i>\n\n<size=3>{info.storyDescription}</size>";
    }

    private void GoBackToTopMenu()
    {
        if (isInSubscreen && InputHub.menuBackButtonDown)
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
