using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DragoonShadesFall : MonoBehaviour
{
    Rigidbody2D rb2d;
    SpriteRenderer spriteRenderer;

    [SerializeField] float baseVerticalKnockback = 3f;

    void Awake()
    {
        rb2d = this.gameObject.GetComponent<Rigidbody2D>();
        spriteRenderer = this.gameObject.GetComponent<SpriteRenderer>();
    }

    public void Setup(Vector2 velocity, bool flipX)
    {
        rb2d.velocity = (Vector2.up * baseVerticalKnockback);
        spriteRenderer.flipX = flipX;
    }

    void OnBecameInvisible()
    {
        GameObject.Destroy(this.gameObject);
    }
}
