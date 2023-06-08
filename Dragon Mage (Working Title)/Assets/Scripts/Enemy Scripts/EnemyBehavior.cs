using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class EnemyBehavior : MonoBehaviour
{
    [SerializeField] UnityEvent onDefeat;

    [HideInInspector] public Rigidbody2D rb2d;
    [HideInInspector] public SpriteRenderer enemySprite;

    [HideInInspector] public EnemyMovement movement;
    [HideInInspector] public EnemyCollisionDetection collisionDetection;
    [HideInInspector] public EnemyPlayerDetection playerDetection;
    [HideInInspector] public EnemyProjectile projectile;

    public bool isStunned { get; private set; }
    public bool isDefeated { get; private set; }

    void Awake()
    {
        rb2d = this.gameObject.GetComponent<Rigidbody2D>();
        enemySprite = this.gameObject.GetComponent<SpriteRenderer>();

        movement = this.gameObject.GetComponent<EnemyMovement>();
        collisionDetection = this.gameObject.GetComponent<EnemyCollisionDetection>();
        playerDetection = this.gameObject.GetComponent<EnemyPlayerDetection>();
        projectile = this.gameObject.GetComponent<EnemyProjectile>();
    }

    void Start()
    {
        
    }

    void Update()
    {
        
    }

    public void DefeatEnemy()
    {
        if (!isDefeated)
        {
            isDefeated = true;
            onDefeat.Invoke();
        }
    }

    public void StunEnemy()
    {

    }
}
