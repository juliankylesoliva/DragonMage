using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WallJumpEffect : MonoBehaviour
{
    SpriteRenderer spriteRenderer;
    Animator animator;

    void Awake()
    {
        animator = this.gameObject.GetComponent<Animator>();
        spriteRenderer = this.gameObject.GetComponent<SpriteRenderer>();
    }

    public void Setup(bool isFacingRight, bool isSpeedy)
    {
        spriteRenderer.flipX = !isFacingRight;
        if (isSpeedy) { animator.Play("FastWallJump"); }
    }
}
