using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Tilemaps;

public class HiddenPassage : MonoBehaviour
{
    Tilemap tilemap;

    [SerializeField] float alphaChangeRate = 5f;
    [SerializeField] Color clearColor;
    [SerializeField] Color solidColor;

    private bool isPlayerInTrigger = false;
    private float currentAlpha = 1f;

    void Awake()
    {
        tilemap = this.gameObject.GetComponent<Tilemap>();
    }

    void Update()
    {
        if (!PauseHandler.isPaused)
        {
            if (isPlayerInTrigger)
            {
                if (currentAlpha > 0f)
                {
                    currentAlpha -= (alphaChangeRate * Time.deltaTime);
                    if (currentAlpha < 0f)
                    {
                        currentAlpha = 0f;
                    }
                }
            }
            else
            {
                if (currentAlpha < 1f)
                {
                    currentAlpha += (alphaChangeRate * Time.deltaTime);
                    if (currentAlpha > 1f)
                    {
                        currentAlpha = 1f;
                    }
                }
            }

            tilemap.color = Color.Lerp(clearColor, solidColor, currentAlpha);
        }
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        if (other.gameObject.tag == "Player") { isPlayerInTrigger = true; }
    }

    void OnTriggerExit2D(Collider2D other)
    {
        if (other.gameObject.tag == "Player") { isPlayerInTrigger = false; }
    }
}
