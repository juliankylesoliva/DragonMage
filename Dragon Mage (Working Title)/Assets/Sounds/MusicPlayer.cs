using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MusicPlayer : MonoBehaviour
{
    [SerializeField] AudioSource[] audioSources;
    [SerializeField] float baseVolume = 0.5f;
    [SerializeField] float fadeoutTime = 3f;
    [SerializeField] AudioClip introClip;
    [SerializeField] AudioClip loopClip;
    [SerializeField] double initialDelay = 0.5;
    [SerializeField] double preloadDelay = 1;

    private AudioClip currentClip;
    private int audioToggle;
    private double musicDuration;
    private double goalTime;

    void Awake()
    {
        foreach (AudioSource src in audioSources)
        {
            SetVolume(src, baseVolume);
        }
    }

    void Start()
    {
        SetCurrentClip(introClip);
        SetInitialGoalTime();
        PlayScheduledClip();
        SetCurrentClip(loopClip);
    }

    void Update()
    {
        if (AudioSettings.dspTime > goalTime - preloadDelay)
        {
            PlayScheduledClip();
        }
    }

    public void FadeOutAndStop()
    {
        foreach (AudioSource src in audioSources)
        {
            StartCoroutine(FadeCR(src, fadeoutTime, 0f));
        }
    }

    public void SetCurrentClip(AudioClip clip)
    {
        currentClip = clip;
    }

    private void SetInitialGoalTime()
    {
        goalTime = AudioSettings.dspTime + initialDelay;
    }

    private void PlayScheduledClip()
    {
        audioSources[audioToggle].clip = currentClip;
        audioSources[audioToggle].PlayScheduled(goalTime);

        musicDuration = (double)currentClip.samples / currentClip.frequency;
        goalTime += musicDuration;

        audioToggle = (1 - audioToggle);
    }

    private void SetVolume(AudioSource src, float newVol)
    {
        src.volume = newVol;
    }

    private IEnumerator FadeCR(AudioSource src, float fadeDuration, float targetVolume)
    {
        float currentTime = 0f;
        float startVolume = src.volume;
        while (currentTime < fadeDuration)
        {
            currentTime += Time.deltaTime;
            src.volume = Mathf.Lerp(startVolume, targetVolume, currentTime / fadeDuration);
            yield return null;
        }

        src.Stop();
        yield break;
    }
}
