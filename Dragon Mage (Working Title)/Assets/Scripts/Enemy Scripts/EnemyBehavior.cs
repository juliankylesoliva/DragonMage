using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyBehavior : MonoBehaviour
{
    [HideInInspector] public Rigidbody2D rb2d;
    [HideInInspector] public SpriteRenderer enemySprite;

    void Awake()
    {
        rb2d = this.gameObject.GetComponent<Rigidbody2D>();
        enemySprite = this.gameObject.GetComponent<SpriteRenderer>();
    }

    void Start()
    {
        
    }

    void Update()
    {
        
    }

    void OnCollisionEnter2D(Collision2D other)
    {
        if (other.gameObject.tag == "Player")
        {
            PlayerCtrl player = other.gameObject.GetComponent<PlayerCtrl>();
            player.damage.TakeDamage(this.transform);
        }
    }
}
