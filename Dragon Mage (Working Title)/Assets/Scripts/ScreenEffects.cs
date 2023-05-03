using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScreenEffects : MonoBehaviour
{
    SpriteRenderer spriteRenderer;

    private bool isEffectInProgress = false;

    void Awake()
    {
        spriteRenderer = this.gameObject.GetComponent<SpriteRenderer>();
    }

    public void ResetToClear()
    {
        if (!isEffectInProgress) { spriteRenderer.color = Color.clear; }
    }

    public void FadeToWhite(float time)
    {
        if (!isEffectInProgress) { StartCoroutine(FadeToWhiteCR(time)); }
    }

    private IEnumerator FadeToWhiteCR(float time)
    {
        if (isEffectInProgress) { yield break; }

        isEffectInProgress = true;

        float currentTime = 0f;
        while (currentTime < time)
        {
            currentTime += Time.deltaTime;
            if (currentTime > time) { currentTime = time; }
            spriteRenderer.color = Color.Lerp(Color.clear, Color.white, currentTime / time);
            yield return null;
        }

        isEffectInProgress = false;
        yield break;
    }
}
