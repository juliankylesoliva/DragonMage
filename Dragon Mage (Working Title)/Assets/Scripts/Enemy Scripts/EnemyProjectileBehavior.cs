using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyProjectileBehavior : MonoBehaviour
{
    SpriteRenderer projectileSprite;
    Rigidbody2D rb2d;

    [SerializeField] float moveSpeed = 3f;
    [SerializeField] float reflectedMoveSpeedMultiplier = 1.5f;
    [SerializeField] float enemyDefeatKnockbackMultiplier = 2f;
    [SerializeField] DamageType damageType = DamageType.REFLECTED_PROJECTILE;
    [SerializeField] string impactEffectName = "DragoonProjectileImpact";
    [SerializeField] string destroySoundName = "enemy_dragoon_projectile_destroy";

    private bool isReflected = false;
    private bool isMovingRight = true;

    void Awake()
    {
        projectileSprite = this.gameObject.GetComponent<SpriteRenderer>();
        rb2d = this.gameObject.GetComponent<Rigidbody2D>();
    }

    void Start()
    {
        
    }

    void Update()
    {
        
    }

    public void Setup(EnemyBehavior enemySource)
    {
        rb2d.velocity = (Vector2.right * enemySource.movement.GetFacingValue() * moveSpeed);
        isMovingRight = (enemySource.movement.GetFacingValue() >= 0f);
        projectileSprite.flipX = !isMovingRight;
    }

    public void ReflectProjectile()
    {
        isReflected = !isReflected;

        Vector2 newVelocity = (-rb2d.velocity * reflectedMoveSpeedMultiplier);
        rb2d.velocity = newVelocity;
        isMovingRight = !isMovingRight;
        projectileSprite.flipX = !projectileSprite.flipX;
    }

    public void DestroyProjectile()
    {
        EffectFactory.SpawnEffect(impactEffectName, this.transform.position);
        SoundFactory.SpawnSound(destroySoundName, this.transform.position);
        GameObject.Destroy(this.gameObject);
    }

    void OnBecameInvisible()
    {
        GameObject.Destroy(this.gameObject);
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        HitCheck(other);
    }

    void OnTriggerStay2D(Collider2D other)
    {
        HitCheck(other);
    }

    private void HitCheck(Collider2D other)
    {
        if (!isReflected && other.transform.tag == "Player")
        {
            PlayerCtrl tempPlayer = other.gameObject.GetComponent<PlayerCtrl>();
            if (tempPlayer != null)
            {
                tempPlayer.damage.TakeDamage(this.transform.position, null, this);
                if (!isReflected) { DestroyProjectile(); }
            }
        }
        else if (isReflected && other.transform.tag == "Enemy")
        {
            EnemyBehavior tempEnemy = other.gameObject.GetComponent<EnemyBehavior>();
            if (tempEnemy != null)
            {
                if (tempEnemy.DefeatEnemy(damageType))
                {
                    tempEnemy.rb2d.velocity += (Vector2.right * (isMovingRight ? 1f : -1f) * rb2d.velocity.magnitude * enemyDefeatKnockbackMultiplier);
                    DestroyProjectile();
                }
            }
        }
        else { /* Nothing */ }
    }
}
