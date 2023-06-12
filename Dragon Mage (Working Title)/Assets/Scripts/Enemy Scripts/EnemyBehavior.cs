using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public enum DamageType { STOMP, MAGIC_BLAST, BLAST_JUMP, FIRE_TACKLE, FIRE_MISSILE }

public class EnemyBehavior : MonoBehaviour
{
    [SerializeField] DamageType[] immuneTo;

    [SerializeField] UnityEvent onRoomActive;
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

    public void ActivateEnemy()
    {
        onRoomActive.Invoke();
    }

    public bool DefeatEnemy(DamageType dmgType)
    {
        if (IsImmune(dmgType)) { return false; }

        if (!isDefeated)
        {
            isDefeated = true;
            onDefeat.Invoke();
            return true;
        }
        return false;
    }

    public void StunEnemy()
    {

    }

    private bool IsImmune(DamageType dmgType)
    {
        foreach (DamageType d in immuneTo)
        {
            if (dmgType == d) { return true; }
        }
        return false;
    }
}
