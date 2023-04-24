using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WallClimbSpark : MonoBehaviour
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
        animator.Play(playerRef.rb2d.velocity.y > playerRef.jumping.baseClimbingSpeed ? "WallClimbSparkFast" : "WallClimbSparkNormal");

        if ((!playerRef.collisions.IsAgainstWall || playerRef.rb2d.velocity.y <= 0f) && playerRef.stateMachine.CurrentState != playerRef.stateMachine.wallClimbingState) { GameObject.Destroy(this.gameObject); }
    }

    public void Setup(PlayerCtrl player)
    {
        playerRef = player;
        spriteRenderer.flipX = !player.movement.isFacingRight;
    }
}
