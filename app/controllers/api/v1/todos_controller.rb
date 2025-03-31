module Api
  module V1
    class TodosController < ApplicationController
      before_action :set_todo, only: [ :show, :update, :destroy ]

      def index
        render json: Todo.all
      end

      def show
        render json: @todo
      end

      def create
        todo = Todo.new(todo_params)
        if todo.save
          render json: todo, status: :created
        else
          render json: { errors: todo.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @todo.update(todo_params)
          render json: @todo
        else
          render json: { errors: @todo.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        @todo.destroy
        head :no_content
      end

      private

      def set_todo
        @todo = Todo.find(params[:id])
      end

      def todo_params
        params.require(:todo).permit(:title)
      end
    end
  end
end
