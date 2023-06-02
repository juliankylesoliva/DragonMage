using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyMovement : MonoBehaviour
{
    EnemyBehavior enemy;

    [SerializeField] Vector2 initialMoveVector;
    [SerializeField] bool ignoreYValue = true;

    private Vector2 currentMoveVector = Vector2.zero;

    void Awake()
    {
        enemy = this.gameObject.GetComponent<EnemyBehavior>();
    }

    void Start()
    {
        SetMoveVector(initialMoveVector); 
    }

    void Update()
    {
        if (!PauseHandler.isPaused)
        {
            enemy.rb2d.velocity = (ignoreYValue ? new Vector2(currentMoveVector.x, enemy.rb2d.velocity.y) : currentMoveVector);
        }
    }

    public void SetMoveVector(Vector2 vector)
    {
        currentMoveVector = vector;
        SetFacingDirection(vector.x);
    }

    public void FlipMovement()
    {
        currentMoveVector *= -1f;
        SetFacingDirection(currentMoveVector.x);
    }

    public void FaceAwayFromPlayer()
    {
        float awayDirection = -enemy.playerDetection.GetDirectionToPlayer();
        if ((currentMoveVector.x * awayDirection) < 0f)
        {
            FlipMovement();
        }
    }

    public void SetFacingDirection(float horizontalDirection)
    {
        if (horizontalDirection != 0f)
        {
            enemy.enemySprite.flipX = (horizontalDirection < 0f);
        }
    }

    public float GetFacingValue()
    {
        return (enemy.enemySprite.flipX ? -1f : 1f);
    }
}
