using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyAnimation : MonoBehaviour
{
    EnemyBehavior enemy;
    Animator animator;

    void Awake()
    {
        enemy = this.gameObject.GetComponent<EnemyBehavior>();
        animator = this.gameObject.GetComponent<Animator>();
    }

    public void DefeatAnimation()
    {
        animator.Play("Defeat");
        animator.speed = 0f;
    }

    public void IdleAnimation()
    {
        animator.Play("Idle");
        animator.speed = 0f;
    }

    public void WalkAnimation()
    {
        animator.Play("Walk");
        animator.speed = 1f;
    }

    public void AttackAnimation(int i)
    {
        switch (i)
        {
            case 0:
                animator.Play("AttackWindup");
                break;
            case 1:
                animator.Play("AttackLaunch");
                break;
            default:
                break;
        }
        animator.speed = 1f;
    }

    public void JumpAnimation()
    {
        animator.Play("Jump");
        animator.speed = 0f;
    }
}
