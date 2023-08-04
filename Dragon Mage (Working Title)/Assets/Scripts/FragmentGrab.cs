using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FragmentGrab : MonoBehaviour
{
    Rigidbody2D rb2d;
    Animator animator;

    [SerializeField] float verticalSpeed = 3f;

    void Awake()
    {
        rb2d = this.gameObject.GetComponent<Rigidbody2D>();
        animator = this.gameObject.GetComponent<Animator>();

        rb2d.velocity = (Vector2.up * verticalSpeed);
    }

    public void Setup(CharacterMode currentMode)
    {
        if (currentMode == CharacterMode.MAGE)
        {
            animator.Play("GrabbedAsMage");
        }
        else
        {
            animator.Play("GrabbedAsDragon");
        }
    }
}
