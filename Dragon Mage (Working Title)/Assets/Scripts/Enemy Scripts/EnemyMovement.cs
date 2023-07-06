using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyMovement : MonoBehaviour
{
    EnemyBehavior enemy;

    [SerializeField] Vector2 initialMoveVector;
    [SerializeField] float turningCooldownTime = 0f;
    [SerializeField] bool ignoreYValue = true;
    public bool isAlwaysFacingPlayer = false;

    private Vector3 initialPosition = Vector3.zero;
    private Vector2 currentMoveVector = Vector2.zero;
    private float currentTurningCooldown = 0f;

    void Awake()
    {
        enemy = this.gameObject.GetComponent<EnemyBehavior>();
        initialPosition = this.transform.position;
    }

    void Start()
    {
        SetMoveVector(initialMoveVector); 
    }

    void Update()
    {
        if (!PauseHandler.isPaused)
        {
            CheckIfFacingPlayer();
            UpdateVelocityVector();
            UpdateCurrentTurningCooldown();
        }
    }

    void OnDisable()
    {
        enemy.rb2d.velocity = Vector2.zero;
    }

    public void SetMoveVector(Vector2 vector)
    {
        currentMoveVector = vector;
        SetFacingDirection(vector.x);
    }

    public void FlipMovement()
    {
        if (IsTurningCooldownActive()) { return; }
        if (currentMoveVector.x != 0f)
        {
            currentMoveVector *= -1f;
            SetFacingDirection(currentMoveVector.x);
        }
        else
        {
            SetFacingDirection(-GetFacingValue());
        }
    }

    public void FlipMovementOverrideCooldown()
    {
        if (currentMoveVector.x != 0f)
        {
            currentMoveVector *= -1f;
            SetFacingDirection(currentMoveVector.x);
        }
        else
        {
            SetFacingDirection(-GetFacingValue());
        }
    }

    public void FaceTowardsPlayer()
    {
        float towardsDirection = enemy.playerDetection.GetDirectionToPlayer();
        if ((GetFacingValue() * towardsDirection) < 0f)
        {
            FlipMovement();
        }
    }

    public void FaceTowardsPlayerOverrideCooldown()
    {
        float towardsDirection = enemy.playerDetection.GetDirectionToPlayer();
        if ((GetFacingValue() * towardsDirection) < 0f)
        {
            FlipMovementOverrideCooldown();
        }
    }

    public void FaceAwayFromPlayer()
    {
        float awayDirection = -enemy.playerDetection.GetDirectionToPlayer();
        if ((currentMoveVector.x * awayDirection) < 0f)
        {
            FlipMovement();
        }
    }

    public void FaceAwayFromPlayerOverrideCooldown()
    {
        float awayDirection = -enemy.playerDetection.GetDirectionToPlayer();
        if ((currentMoveVector.x * awayDirection) < 0f)
        {
            FlipMovementOverrideCooldown();
        }
    }

    public void SetFacingDirection(float horizontalDirection)
    {
        if (horizontalDirection != 0f)
        {
            bool previousFlipX = enemy.enemySprite.flipX;
            enemy.enemySprite.flipX = (horizontalDirection < 0f);
            if (turningCooldownTime > 0f && ((previousFlipX && !enemy.enemySprite.flipX) || (!previousFlipX && enemy.enemySprite.flipX))) { SetTurningCooldown(); }
        }
    }

    public float GetFacingValue()
    {
        return (enemy.enemySprite.flipX ? -1f : 1f);
    }

    public float GetNormalizedXMovement()
    {
        if (currentMoveVector.x != 0)
        {
            return (currentMoveVector.x < 0f ? -1f : 1f);
        }
        else
        {
            return GetFacingValue();
        }
    }

    public void ResetToInitialPosition()
    {
        this.transform.position = initialPosition;
    }

    public void ResetToInitialMoveVector()
    {
        SetMoveVector(initialMoveVector);
    }

    private void CheckIfFacingPlayer()
    {
        if (isAlwaysFacingPlayer) { FaceTowardsPlayer(); }
    }

    private void UpdateVelocityVector()
    {
        enemy.rb2d.velocity = (ignoreYValue ? new Vector2(currentMoveVector.x, enemy.rb2d.velocity.y) : currentMoveVector);
    }

    private void UpdateCurrentTurningCooldown()
    {
        if (currentTurningCooldown > 0f)
        {
            currentTurningCooldown -= Time.deltaTime;
            if (currentTurningCooldown < 0f)
            {
                currentTurningCooldown = 0f;
            }
        }
    }

    private void SetTurningCooldown()
    {
        if (currentTurningCooldown <= 0f) { currentTurningCooldown = turningCooldownTime; }
    }

    private bool IsTurningCooldownActive()
    {
        return currentTurningCooldown > 0f;
    }
}
