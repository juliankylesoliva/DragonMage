using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScreenEffects : MonoBehaviour
{
    SpriteRenderer spriteRenderer;

    [SerializeField] bool startWithFadeIn = false;
    [SerializeField] Color startFadeInColor;
    [SerializeField] float startFadeInTime = 0.25f;

    private bool isEffectInProgress = false;

    void Awake()
    {
        spriteRenderer = this.gameObject.GetComponent<SpriteRenderer>();
    }

    void Start()
    {
        if (startWithFadeIn) { StartCoroutine(ColorFadeCR(startFadeInTime, startFadeInColor, Color.clear)); }
    }

    public void ResetToClear()
    {
        if (!isEffectInProgress) { spriteRenderer.color = Color.clear; }
    }

    public void FadeToWhite(float time)
    {
        if (!isEffectInProgress) { StartCoroutine(ColorFadeCR(time, Color.clear, Color.white)); }
    }

    public void FadeToBlack(float time)
    {
        if (!isEffectInProgress) { StartCoroutine(ColorFadeCR(time, Color.clear, Color.black)); }
    }

    private IEnumerator ColorFadeCR(float time, Color from, Color to)
    {
        if (isEffectInProgress) { yield break; }

        isEffectInProgress = true;

        float currentTime = 0f;
        while (currentTime < time)
        {
            currentTime += Time.deltaTime;
            if (currentTime > time) { currentTime = time; }
            spriteRenderer.color = Color.Lerp(from, to, currentTime / time);
            yield return null;
        }

        isEffectInProgress = false;
        yield break;
    }
}
