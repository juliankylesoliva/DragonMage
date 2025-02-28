using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum EnemyProjectileState { STANDBY, WINDUP, COOLDOWN }

public class EnemyProjectile : MonoBehaviour
{
    EnemyBehavior enemy;

    [SerializeField] GameObject enemyProjectilePrefab;
    public Transform enemyProjectileSpawnPoint;
    [SerializeField] float preFireWindup = 0.5f;
    [SerializeField] float postFireCooldown = 3f;

    public EnemyProjectileState currentProjectileState { get; private set; }

    private float currentProjectileStateTimer = 0f;

    void Awake()
    {
        enemy = this.gameObject.GetComponent<EnemyBehavior>();
    }

    void Start()
    {
        ResetTimerAndState();
    }

    void Update()
    {
        if (!PauseHandler.isPaused && !enemy.isDefeated)
        {
            UpdateStateTimer();
        }
    }

    public void LaunchProjectile()
    {
        if (currentProjectileState != EnemyProjectileState.STANDBY || !enemy.isVisible) { return; }
        currentProjectileState = EnemyProjectileState.WINDUP;
        currentProjectileStateTimer = preFireWindup;
        enemy.animationCtrl.AttackAnimation(0);
    }

    public void ResetTimerAndState()
    {
        currentProjectileState = EnemyProjectileState.STANDBY;
        currentProjectileStateTimer = 0f;
    }

    private void UpdateStateTimer()
    {
        if (currentProjectileState == EnemyProjectileState.WINDUP || currentProjectileState == EnemyProjectileState.COOLDOWN)
        {
            if (currentProjectileStateTimer > 0f)
            {
                currentProjectileStateTimer -= Time.deltaTime;
            }
            
            if (currentProjectileStateTimer <= 0f)
            {
                if (currentProjectileState == EnemyProjectileState.WINDUP)
                {
                    GameObject projTemp = Instantiate(enemyProjectilePrefab, enemyProjectileSpawnPoint.position, Quaternion.identity);
                    EnemyProjectileBehavior projBehavior = projTemp.GetComponent<EnemyProjectileBehavior>();
                    projBehavior.Setup(enemy);
                    currentProjectileState = EnemyProjectileState.COOLDOWN;
                    currentProjectileStateTimer = postFireCooldown;
                    enemy.animationCtrl.AttackAnimation(1);
                }
                else
                {
                    currentProjectileState = EnemyProjectileState.STANDBY;
                    currentProjectileStateTimer = 0f;
                    enemy.animationCtrl.IdleAnimation();
                }
            }
        }
    }
}
