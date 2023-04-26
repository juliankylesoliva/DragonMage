using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WallSlideDust : MonoBehaviour
{
    SpriteRenderer spriteRenderer;
    Animator animator;
    PlayerCtrl playerRef;

    void Awake()
    {
        animator = this.gameObject.GetComponent<Animator>();
        spriteRenderer = this.gameObject.GetComponent<SpriteRenderer>();
    }

    void Update()
    {
        if (playerRef.stateMachine.CurrentState != playerRef.stateMachine.wallSlidingState) { GameObject.Destroy(this.gameObject); }
    }

    public void Setup(PlayerCtrl player)
    {
        playerRef = player;
        spriteRenderer.flipX = !player.movement.isFacingRight;
    }
}
