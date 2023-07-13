using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class InputHub : MonoBehaviour
{
    PlayerInput playerInput;

    public string currentControlScheme { get { return playerInput.currentControlScheme; } }

    public static Vector2 inputVector { get; private set; }

    public static bool jumpButtonDown { get; private set; }
    public static bool jumpButtonHeld { get; private set; }

    public static bool attackButtonDown { get; private set; }
    public static bool attackButtonHeld { get; private set; }

    public static bool formChangeButtonDown { get; private set; }

    public static bool interactButtonDown { get; private set; }

    public static bool technicalButtonHeld { get; private set; }

    void Awake()
    {
        playerInput = this.gameObject.GetComponent<PlayerInput>();
    }

    void LateUpdate()
    {
        if (jumpButtonDown) { jumpButtonDown = false; }
        if (attackButtonDown) { attackButtonDown = false; }
        if (formChangeButtonDown) { formChangeButtonDown = false; }
        if (interactButtonDown) { interactButtonDown = false; }
    }

    void OnDeviceLost()
    {
        Debug.Log("Device Lost!");
    }

    void OnDeviceRegained()
    {
        Debug.Log("Device Regained!");
    }

    void OnControlsChanged()
    {
        Debug.Log("Controls Changed!");
    }

    void OnMove(InputValue value)
    {
        Vector2 incomingVector = value.Get<Vector2>();

        if (incomingVector.x != 0f)
        {
            if (incomingVector.x > 0f)
            {
                if (incomingVector.x < 1f) { incomingVector.x = 1f; }
            }
            else
            {
                if (incomingVector.x > -1f) { incomingVector.x = -1f; }
            }
        }

        if (incomingVector.y != 0f)
        {
            if (incomingVector.y > 0f)
            {
                if (incomingVector.y < 1f) { incomingVector.y = 1f; }
            }
            else
            {
                if (incomingVector.y > -1f) { incomingVector.y = -1f; }
            }
        }

        inputVector = incomingVector;
    }

    void OnJump(InputValue value)
    {
        jumpButtonHeld = value.isPressed;
        if (jumpButtonHeld) { jumpButtonDown = true; }
    }

    void OnAttack(InputValue value)
    {
        attackButtonHeld = value.isPressed;
        if (attackButtonHeld) { attackButtonDown = true; }
    }

    void OnChange(InputValue value)
    {
        if (value.isPressed) { formChangeButtonDown = true; }
    }

    void OnInteract(InputValue value)
    {
        if (value.isPressed) { interactButtonDown = true; }
    }

    void OnTechnical(InputValue value)
    {
        technicalButtonHeld = value.isPressed;
    }

    void OnPause()
    {

    }

    void OnMenuUp()
    {

    }

    void OnMenuDown()
    {

    }

    void OnMenuRight()
    {

    }

    void OnMenuLeft()
    {

    }

    void OnMenuSelect()
    {

    }

    void OnMenuBack()
    {

    }

    void OnToTitleScreen()
    {

    }
}
