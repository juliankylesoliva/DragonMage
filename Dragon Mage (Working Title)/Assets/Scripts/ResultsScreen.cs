using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using TMPro;

public class ResultsScreen : MonoBehaviour
{
    AudioPlayer audioPlayer;

    [SerializeField] PlayerDamage playerDamageRef;

    [SerializeField] Color clearColor;
    [SerializeField] Color semiTransparentColor;
    [SerializeField] Color magicalMedallionTextColor;
    [SerializeField] Color draconicMedallionTextColor;
    [SerializeField] Color balancedMedallionTextColor;

    [SerializeField] SpriteRenderer screenColor;
    [SerializeField] TMP_Text headerText;
    [SerializeField] TMP_Text fragmentsText;
    [SerializeField] TMP_Text damageText;
    [SerializeField] TMP_Text timeText;
    [SerializeField] TMP_Text medallionText;
    [SerializeField] TMP_Text controlPromptText;

    [SerializeField] float fadeInTime = 0.5f;
    [SerializeField] float countUpTime = 0.35f;

    private bool isDisplayingResults = false;

    void Awake()
    {
        audioPlayer = this.gameObject.GetComponent<AudioPlayer>();
    }

    public void DisplayResults()
    {
        if (!isDisplayingResults)
        {
            StartCoroutine(DisplayResultsCR());
        }
    }

    private IEnumerator DisplayResultsCR()
    {
        if (isDisplayingResults) { yield break; }
        isDisplayingResults = true;

        yield return new WaitForSeconds(1f);

        Vector3 toPosition = Camera.main.transform.position;
        toPosition.z = 0f;
        this.transform.position = toPosition;

        float lerpValue = 0f;
        while (lerpValue < 1f)
        {
            lerpValue += (Time.deltaTime / fadeInTime);
            if (lerpValue > 1f) { lerpValue = 1f; }
            screenColor.color = Color.Lerp(clearColor, semiTransparentColor, lerpValue);
            yield return null;
        }

        headerText.gameObject.SetActive(true);

        yield return new WaitForSeconds(0.5f);

        fragmentsText.gameObject.SetActive(true);
        int previousFragmentDisplayNumber = 0;
        int currentFragmentDisplayNumber = 0;
        int targetFragmentDisplayNumber = MedalFragment.totalFragments;
        lerpValue = 0;
        while (lerpValue < 1f)
        {
            lerpValue += (Time.deltaTime / countUpTime);
            if (lerpValue > 1f) { lerpValue = 1f; }
            currentFragmentDisplayNumber = (int)Mathf.Lerp(0f, (float)targetFragmentDisplayNumber, lerpValue);
            if (currentFragmentDisplayNumber != previousFragmentDisplayNumber) { audioPlayer.PlaySound("object_fragment_pickup", 0.5f); }
            previousFragmentDisplayNumber = currentFragmentDisplayNumber;
            fragmentsText.text = $"FRAGMENTS COLLECTED: {currentFragmentDisplayNumber} / {Level.FragmentsNeededForMedal}";
            yield return null;
        }
        fragmentsText.text = $"FRAGMENTS COLLECTED: {targetFragmentDisplayNumber} / {Level.FragmentsNeededForMedal}";

        yield return new WaitForSeconds(countUpTime);

        damageText.gameObject.SetActive(true);
        int previousDamageDisplayNumber = 0;
        int currentDamageDisplayNumber = 0;
        int targetDamageDisplayNumber = playerDamageRef.damageTaken;
        lerpValue = 0;
        while (lerpValue < 1f)
        {
            lerpValue += (Time.deltaTime / countUpTime);
            if (lerpValue > 1f) { lerpValue = 1f; }
            currentDamageDisplayNumber = (int)Mathf.Lerp(0f, (float)targetDamageDisplayNumber, lerpValue);
            if (currentDamageDisplayNumber != previousDamageDisplayNumber) { audioPlayer.PlaySound("damage_player", 0.5f); }
            previousDamageDisplayNumber = currentDamageDisplayNumber;
            damageText.text = $"DAMAGE TAKEN: {currentDamageDisplayNumber}";
            yield return null;
        }
        damageText.text = $"DAMAGE TAKEN: {targetDamageDisplayNumber}";

        yield return new WaitForSeconds(countUpTime);

        timeText.gameObject.SetActive(true);
        float currentTimeDisplayNumber = 0f;
        float targetTimeDisplayNumber = ClearTimer.currentTime;
        int minutes = 0;
        float seconds = 0f;
        bool playSoundThisFrame = true;
        lerpValue = 0f;
        while (lerpValue < 1f)
        {
            lerpValue += (Time.deltaTime / countUpTime);
            if (lerpValue > 1f) { lerpValue = 1f; }
            currentTimeDisplayNumber = Mathf.Lerp(0f, targetTimeDisplayNumber, lerpValue);
            minutes = (int)(currentTimeDisplayNumber / 60f);
            seconds = (currentTimeDisplayNumber % 60f);
            if (playSoundThisFrame) { audioPlayer.PlaySound("movement_magli_turnaround", 0.5f); }
            timeText.text = $"CLEAR TIME: {minutes}:{seconds.ToString("00.00")}";
            playSoundThisFrame = !playSoundThisFrame;
            yield return null;
        }
        timeText.text = $"CLEAR TIME: {minutes}:{seconds.ToString("00.00")}";

        yield return new WaitForSeconds(countUpTime);

        medallionText.gameObject.SetActive(true);
        switch (MedalPickup.medalPickedUpStatus)
        {
            case MedalStatus.MAGIC_MEDAL_GET:
                medallionText.color = magicalMedallionTextColor;
                medallionText.text = $"FOUND A MAGICAL MEDALLION!";
                SoundFactory.SpawnSound("object_medal_pickup", this.transform.position, 0.5f);
                SoundFactory.SpawnSound("transformation_magli", this.transform.position, 0.5f);
                break;
            case MedalStatus.DRAGON_MEDAL_GET:
                medallionText.color = draconicMedallionTextColor;
                medallionText.text = $"FOUND A DRACONIC MEDALLION!";
                SoundFactory.SpawnSound("object_medal_pickup", this.transform.position, 0.5f);
                SoundFactory.SpawnSound("transformation_draelyn", this.transform.position, 0.5f);
                break;
            case MedalStatus.BALANCE_MEDAL_GET:
                medallionText.color = balancedMedallionTextColor;
                medallionText.text = $"FOUND A BALANCED MEDALLION!";
                SoundFactory.SpawnSound("object_medal_pickup", this.transform.position, 0.5f);
                SoundFactory.SpawnSound("transformation_magli", this.transform.position, 0.5f);
                SoundFactory.SpawnSound("transformation_draelyn", this.transform.position, 0.5f);
                break;
            default:
                medallionText.color = Color.white;
                medallionText.text = $"NO MEDALLION FOUND...";
                SoundFactory.SpawnSound("transformation_magli_locked", this.transform.position, 0.5f);
                SoundFactory.SpawnSound("transformation_draelyn_locked", this.transform.position, 0.5f);
                break;
        }

        yield return new WaitForSeconds(fadeInTime);

        controlPromptText.gameObject.SetActive(true);
        InputHub.playerInput.SwitchCurrentActionMap("Menus");

        while (!InputHub.menuSelectButtonDown && !InputHub.titleScreenButtonDown) { yield return null; }

        if (InputHub.menuSelectButtonDown)
        {
            Scene scene = SceneManager.GetActiveScene();
            SceneManager.LoadScene(scene.name);
        }
        else
        {
            SceneManager.LoadScene("TitleScreen");
        }

        yield return null;
    }
}
