using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class InputHub : MonoBehaviour
{
    public static PlayerInput playerInput { get; private set; }
    
    /* In-Game Controls */
    public static Vector2 inputVector { get; private set; }

    public static bool jumpButtonDown { get; private set; }
    public static bool jumpButtonHeld { get; private set; }

    public static bool attackButtonDown { get; private set; }
    public static bool attackButtonHeld { get; private set; }

    public static bool crouchButtonHeld { get; private set; }

    public static bool formChangeButtonDown { get; private set; }

    public static bool interactButtonDown { get; private set; }

    public static bool technicalButtonHeld { get; private set; }

    /* Miscellaneous and Menu Controls */
    public static bool pauseButtonDown { get; private set; }

    public static bool menuUpButtonDown { get; private set; }
    public static bool menuUpButtonHeld { get; private set; }

    public static bool menuDownButtonDown { get; private set; }
    public static bool menuDownButtonHeld { get; private set; }

    public static bool menuRightButtonDown { get; private set; }
    public static bool menuRightButtonHeld { get; private set; }

    public static bool menuLeftButtonDown { get; private set; }
    public static bool menuLeftButtonHeld { get; private set; }

    public static bool menuSelectButtonDown { get; private set; }
    public static bool menuSelectButtonHeld { get; private set; }

    public static bool menuBackButtonDown { get; private set; }
    public static bool menuBackButtonHeld { get; private set; }

    public static bool titleScreenButtonDown { get; private set; }
    public static bool titleScreenButtonHeld { get; private set; }

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

        if (pauseButtonDown) { pauseButtonDown = false; }
        if (menuUpButtonDown) { menuUpButtonDown = false; }
        if (menuDownButtonDown) { menuDownButtonDown = false; }
        if (menuRightButtonDown) { menuRightButtonDown = false; }
        if (menuLeftButtonDown) { menuLeftButtonDown = false; }
        if (menuSelectButtonDown) { menuSelectButtonDown = false; }
        if (menuBackButtonDown) { menuBackButtonDown = false; }
        if (titleScreenButtonDown) { titleScreenButtonDown = false; }
    }

    void OnDeviceLost()
    {
        
    }

    void OnDeviceRegained()
    {
        
    }

    void OnControlsChanged()
    {
        
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

    void OnCrouch(InputValue value)
    {
        crouchButtonHeld = value.isPressed;
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

    void OnPause(InputValue value)
    {
        if (value.isPressed) { pauseButtonDown = true; }
    }

    void OnMenuUp(InputValue value)
    {
        menuUpButtonHeld = value.isPressed;
        if (menuUpButtonHeld) { menuUpButtonDown = true; }
    }

    void OnMenuDown(InputValue value)
    {
        menuDownButtonHeld = value.isPressed;
        if (menuDownButtonHeld) { menuDownButtonDown = true; }
    }

    void OnMenuRight(InputValue value)
    {
        menuRightButtonHeld = value.isPressed;
        if (menuRightButtonHeld) { menuRightButtonDown = true; }
    }

    void OnMenuLeft(InputValue value)
    {
        menuLeftButtonHeld = value.isPressed;
        if (menuLeftButtonHeld) { menuLeftButtonDown = true; }
    }

    void OnMenuSelect(InputValue value)
    {
        menuSelectButtonHeld = value.isPressed;
        if (menuSelectButtonHeld) { menuSelectButtonDown = true; }
    }

    void OnMenuBack(InputValue value)
    {
        menuBackButtonHeld = value.isPressed;
        if (menuBackButtonHeld) { menuBackButtonDown = true; }
    }

    void OnToTitleScreen(InputValue value)
    {
        titleScreenButtonHeld = value.isPressed;
        if (titleScreenButtonHeld) { titleScreenButtonDown = true; }
    }

    public static void ClearInputs()
    {
        inputVector = Vector2.zero;
        jumpButtonDown = false;
        jumpButtonHeld = false;
        attackButtonDown = false;
        attackButtonHeld = false;
        crouchButtonHeld = false;
        formChangeButtonDown = false;
        interactButtonDown = false;
        technicalButtonHeld = false;
    }
}
