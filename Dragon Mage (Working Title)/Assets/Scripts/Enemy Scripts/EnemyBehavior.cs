using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyBehavior : MonoBehaviour
{
    [HideInInspector] public Rigidbody2D rb2d;
    [HideInInspector] public SpriteRenderer enemySprite;

    [HideInInspector] public EnemyMovement movement;
    [HideInInspector] public EnemyCollisionDetection collisionDetection;
    [HideInInspector] public EnemyPlayerDetection playerDetection;
    [HideInInspector] public EnemyProjectile projectile;

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
}
