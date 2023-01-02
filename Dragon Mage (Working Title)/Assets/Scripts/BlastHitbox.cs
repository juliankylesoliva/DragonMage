using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(CircleCollider2D))]
public class BlastHitbox : MonoBehaviour
{
    CircleCollider2D circle;

    private bool isArmed = false;
    private float hitboxDuration = 0f;
    private float knockbackStrength = 0f;

    void Awake()
    {
        circle = this.gameObject.GetComponent<CircleCollider2D>();
    }

    void Update()
    {
        if (isArmed)
        {
            hitboxDuration -= Time.deltaTime;
            if (hitboxDuration <= 0f)
            {
                GameObject.Destroy(this.gameObject);
            }
        }
    }

    public void Setup(float duration, float strength, float radius)
    {
        isArmed = true;
        hitboxDuration = duration;
        knockbackStrength = strength;
        circle.radius = radius;
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        Rigidbody2D rb = other.gameObject.GetComponent<Rigidbody2D>();
        if (rb != null && rb.bodyType == RigidbodyType2D.Dynamic)
        {
            Vector2 velocityVec = (other.transform.position - this.transform.position);
            float distance = velocityVec.magnitude;
            velocityVec = velocityVec.normalized;
            velocityVec *= (knockbackStrength / (1f + distance));
            rb.velocity += velocityVec;
        }
    }
}
