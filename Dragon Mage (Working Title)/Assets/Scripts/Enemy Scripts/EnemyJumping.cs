using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyJumping : MonoBehaviour
{
    EnemyBehavior enemy;

    [SerializeField] float jumpSpeed = 4f;
    [SerializeField] float risingGravity = 1f;
    [SerializeField] float fallingGravity = 1f;
    [SerializeField] float fallSpeed = 6f;

    void Awake()
    {
        enemy = this.gameObject.GetComponent<EnemyBehavior>();
    }

    void Start()
    {
        enemy.rb2d.gravityScale = fallingGravity;
    }

    void Update()
    {
        if (!PauseHandler.isPaused && !enemy.isDefeated)
        {
            JumpUpdate();
        }
    }

    public void Jump()
    {
        if (enemy.collisionDetection.isGrounded)
        {
            enemy.rb2d.gravityScale = risingGravity;
            enemy.rb2d.velocity = new Vector2(enemy.rb2d.velocity.x, jumpSpeed);
        }
    }

    private void JumpUpdate()
    {
        if (!enemy.collisionDetection.isGrounded)
        {
            float currentFallSpeed = enemy.rb2d.velocity.y;
            if (currentFallSpeed < 0f)
            {
                enemy.rb2d.gravityScale = fallingGravity;
                if (currentFallSpeed < -fallSpeed)
                {
                    enemy.rb2d.velocity = new Vector2(enemy.rb2d.velocity.x, -fallSpeed);
                }
            }
        }
    }
}
