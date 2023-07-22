using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SlideDust : MonoBehaviour
{
    SpriteRenderer spriteRenderer;
    Animator animator;
    PlayerCtrl playerRef;

    [SerializeField] float baseSpeed = 8f;
    [SerializeField] float fastThreshold = 1.5f;
    [SerializeField] float slowThreshold = 0.5f;

    void Awake()
    {
        animator = this.gameObject.GetComponent<Animator>();
        spriteRenderer = this.gameObject.GetComponent<SpriteRenderer>();
    }

    void Update()
    {
        float currentSlideSpeed = Mathf.Abs(playerRef.rb2d.velocity.x);
        float speedRatio = (currentSlideSpeed / baseSpeed);
        if (speedRatio >= fastThreshold)
        {
            animator.Play("FastSlide");
        }
        else if (speedRatio <= slowThreshold)
        {
            animator.Play("SlowSlide");
        }
        else
        {
            animator.Play("MediumSlide");
        }

        this.transform.up = playerRef.collisions.GetGroundNormal();
        this.transform.position = playerRef.collisions.GetClosestGroundPoint();

        if (playerRef.stateMachine.CurrentState != playerRef.stateMachine.slidingState) { GameObject.Destroy(this.gameObject); }
    }

    public void Setup(PlayerCtrl player)
    {
        playerRef = player;
        spriteRenderer.flipX = !player.movement.isFacingRight;
    }
}
