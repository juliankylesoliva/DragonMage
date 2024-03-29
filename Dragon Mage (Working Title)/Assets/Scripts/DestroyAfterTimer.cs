using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DestroyAfterTimer : MonoBehaviour
{
    SpriteRenderer spriteRenderer;

    [SerializeField] float expireTime = 0.5f;
    [SerializeField] bool shrinkToZero = false;
    [SerializeField] bool fadeSpriteToZero = false;
    [SerializeField] bool fadeToBlack = false;
    [SerializeField] bool enableSpriteFlip = false;
    [SerializeField] int flipSpriteXInterval = 6;

    private float currentTimer = 0f;
    private int currentFrameTimer = 0;
    private float startingXScale = 0f;
    private float startingYScale = 0f;
    private Color startingColor;
    private Color endingColor;

    void Awake()
    {
        if (fadeSpriteToZero || fadeToBlack || enableSpriteFlip) { spriteRenderer = this.gameObject.GetComponent<SpriteRenderer>(); }
    }

    void Start()
    {
        if (shrinkToZero) { startingXScale = this.transform.localScale.x; startingYScale = this.transform.localScale.y; }
        if ((fadeSpriteToZero || fadeToBlack) && spriteRenderer != null) { startingColor = spriteRenderer.color; endingColor = (fadeToBlack ? Color.black : startingColor); if (fadeSpriteToZero) { endingColor.a = 0f; } }
        if (fadeToBlack && spriteRenderer != null) { endingColor = Color.black; }
        currentTimer = expireTime;
    }

    void Update()
    {
        if (PauseHandler.isPaused) { return; }

        if (currentTimer > 0f)
        {
            currentTimer -= Time.deltaTime;
            if (enableSpriteFlip && spriteRenderer != null)
            {
                currentFrameTimer++;
                if (currentFrameTimer == flipSpriteXInterval)
                {
                    currentFrameTimer = 0;
                    spriteRenderer.flipX = !spriteRenderer.flipX;
                }
            }
            if (shrinkToZero) { this.transform.localScale = Vector3.Lerp(new Vector3(startingXScale, startingYScale, 1f), Vector3.forward, (expireTime - currentTimer) / expireTime); }
            if ((fadeSpriteToZero || fadeToBlack) && spriteRenderer != null) { spriteRenderer.color = Color.Lerp(startingColor, endingColor, (expireTime - currentTimer) / expireTime); }
            if (currentTimer <= 0f) { GameObject.Destroy(this.gameObject); }
        }
    }
}
