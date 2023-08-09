using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DroppedFragment : MonoBehaviour
{
    SpriteRenderer spriteRenderer;
    Rigidbody2D rb2d;

    [SerializeField] Color mageColor;
    [SerializeField] Color dragonColor;
    [SerializeField] float clearAlpha = 0.75f;

    private bool isClear = false;

    void Awake()
    {
        spriteRenderer = this.gameObject.GetComponent<SpriteRenderer>();
        rb2d = this.gameObject.GetComponent<Rigidbody2D>();
    }

    void Update()
    {
        Color tempColor = spriteRenderer.color;
        tempColor.a = (isClear ? clearAlpha : 1f);
        spriteRenderer.color = tempColor;
        isClear = !isClear;
    }

    public void Setup(Vector2 velocity, bool isDragonFragment)
    {
        rb2d.velocity = velocity;
        spriteRenderer.color = (isDragonFragment ? dragonColor : mageColor);
    }
}
