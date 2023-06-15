using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyProjectileBehavior : MonoBehaviour
{
    SpriteRenderer projectileSprite;
    Rigidbody2D rb2d;

    [SerializeField] float moveSpeed = 3f;

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
        projectileSprite.flipX = (enemySource.movement.GetFacingValue() < 0f);
    }

    void OnBecameInvisible()
    {
        GameObject.Destroy(this.gameObject);
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        PlayerHitCheck(other);
    }

    void OnTriggerStay2D(Collider2D other)
    {
        PlayerHitCheck(other);
    }

    private void PlayerHitCheck(Collider2D other)
    {
        if (other.transform.tag == "Player")
        {
            PlayerCtrl tempPlayer = other.gameObject.GetComponent<PlayerCtrl>();
            if (tempPlayer != null) { tempPlayer.damage.TakeDamage(this.transform); }
        }
        else { /* Nothing */ }
    }
}
